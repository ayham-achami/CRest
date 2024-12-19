//
//  CombineAlamofireRestIO.swift
//

#if canImport(Combine)
import Alamofire
import Combine
import Foundation

/// Имплементация RestIO с Alamofire и Combine
public final class CombineAlamofireRestIO: CombineRestIO {
    
    /// Сессия запросов
    private let session: Session
    /// Очередь запросов
    private let networkQueue: DispatchQueue
    /// Очередь запросов
    private let requestsQueue: DispatchQueue
    /// Очередь десериализации
    private let serializationQueue: DispatchQueue
    /// Общие настройки REST клиента
    private let configuration: RestIOConfiguration
    
    public init(_ configuration: RestIOConfiguration) {
        self.configuration = configuration
        let id = UUID().uuidString
        let networkQueue = DispatchQueue(label: "RestIO.combine.networkQueue.\(id)", qos: .default)
        let requestsQueue = DispatchQueue(label: "RestIO.combine.requestsQueue.\(id)", qos: .default, attributes: .concurrent, target: networkQueue)
        let serializationQueue = DispatchQueue(label: "RestIO.combine.serializationQueue.\(id)", qos: .default, attributes: .concurrent, target: networkQueue)
        self.session = Session(configuration: configuration.sessionConfiguration ?? URLSessionConfiguration.af.default,
                               rootQueue: networkQueue,
                               requestQueue: requestsQueue,
                               serializationQueue: serializationQueue,
                               interceptor: configuration.sessionInterceptor?.afInterceptor,
                               serverTrustManager: configuration.serverTrustManager,
                               cachedResponseHandler: configuration.cachedResponseHandler)
        self.networkQueue = networkQueue
        self.requestsQueue = requestsQueue
        self.serializationQueue = serializationQueue
    }
    
    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) -> AnyPublisher<Response, Error> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        return requester.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response in
                self?.configuration.informant.log(response)
                switch response.result {
                case let .success(model):
                    return model
                case let .failure(error):
                    throw error.reason(with: response.response?.statusCode, responseData: response.data)
                }
            }.eraseToAnyPublisher()
    }
    
    public func dynamicPerform<Response>(_ request: DynamicRequest,
                                         response: Response.Type) -> AnyPublisher<DynamicResponse<Response>, Error> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        return requester.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response in
                self?.configuration.informant.log(response)
                switch response.result {
                case let .success(model):
                    return .init(model, response.response)
                case let .failure(error):
                    throw error.reason(with: response.response?.statusCode, responseData: response.data)
                }
            }.eraseToAnyPublisher()
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        let downloader = IO.with(session).downloadRequest(for: request, into: destination)
        let responsePublisher = downloader.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response -> Response in
                self?.configuration.informant.log(response)
                switch response.result {
                case let .success(model):
                    return model
                case let .failure(error):
                    throw error.reason(with: response.response?.statusCode)
                }
            }
        let progressSubject = PassthroughSubject<Progress, Swift.Never>()
        downloader.downloadProgress { progress in
            progressSubject.send(progress)
            if progress.isFinished || progress.isCancelled {
                progressSubject.send(completion: .finished)
            }
        }
        return .init(response: responsePublisher.eraseToAnyPublisher(), progress: progressSubject.eraseToAnyPublisher())
    }
    
    public func upload<Response>(from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        let uploader = IO.with(session).uploadRequest(for: request, from: source)
        let responsePublisher = uploader
            .publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response -> Response in
                self?.configuration.informant.log(response)
                switch response.result {
                case let .success(model):
                    return model
                case let .failure(error):
                    throw error.reason(with: response.response?.statusCode)
                }
            }
        let progressSubject = PassthroughSubject<Progress, Swift.Never>()
        uploader.uploadProgress { progress in
            progressSubject.send(progress)
            if progress.isFinished || progress.isCancelled {
                progressSubject.send(completion: .finished)
            }
        }
        return .init(response: responsePublisher.eraseToAnyPublisher(), progress: progressSubject.eraseToAnyPublisher())
    }
}
#endif
