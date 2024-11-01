//
//  CombineAlamofireRestIO.swift
//

#if canImport(Combine)
import Alamofire
@preconcurrency import Combine
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
                                  response: Response.Type) -> AnyPublisher<Response, NetworkError> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        configuration.informant.log(request: requester)
        return requester.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response in
                self?.configuration.informant.log(response: response)
                switch response.result {
                case let .success(model):
                    self?.configuration.informant.log(response: response)
                    return model
                case let .failure(error):
                    self?.configuration.informant.log(error: error)
                    self?.configuration.informant.logError(response: response)
                    throw error.reason(with: response.response?.statusCode, responseData: response.data)
                }
            }
            .setFailureNetworkError()
            .eraseToAnyPublisher()
    }
    
    public func dynamicPerform<Response>(_ request: DynamicRequest,
                                         response: Response.Type) -> AnyPublisher<DynamicResponse<Response>, NetworkError> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        configuration.informant.log(request: requester)
        return requester.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response in
                switch response.result {
                case let .success(model):
                    self?.configuration.informant.log(response: response)
                    return .init(model, response.response)
                case let .failure(error):
                    self?.configuration.informant.log(error: error)
                    self?.configuration.informant.logError(response: response)
                    throw error.reason(with: response.response?.statusCode, responseData: response.data)
                }
            }
            .setFailureNetworkError()
            .eraseToAnyPublisher()
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        let downloader = IO.with(session).downloadRequest(for: request, into: destination)
        configuration.informant.log(request: downloader)
        let responsePublisher = downloader.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response -> Response in
                switch response.result {
                case let .success(model):
                    self?.configuration.informant.log(response: response)
                    return model
                case let .failure(error):
                    self?.configuration.informant.log(error: error)
                    self?.configuration.informant.logError(response: response)
                    throw error.reason(with: response.response?.statusCode)
                }
            }.setFailureNetworkError()
        let progressSubject = PassthroughSubject<Progress, Swift.Never>()
        downloader.downloadProgress { progress in
            progressSubject.send(progress)
            if progress.isFinished || progress.isCancelled {
                progressSubject.send(completion: .finished)
            }
        }
        return .init(response: responsePublisher.eraseToAnyPublisher(),
                     progress: progressSubject.eraseToAnyPublisher())
    }
    
    public func upload<Response>(from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        let uploader = IO.with(session).uploadRequest(for: request, from: source)
        configuration.informant.log(request: uploader)
        let responsePublisher = uploader
            .publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response -> Response in
                switch response.result {
                case let .success(model):
                    self?.configuration.informant.log(response: response)
                    return model
                case let .failure(error):
                    self?.configuration.informant.log(error: error)
                    self?.configuration.informant.logError(response: response)
                    throw error.reason(with: response.response?.statusCode)
                }
            }.setFailureNetworkError()
        let progressSubject = PassthroughSubject<Progress, Swift.Never>()
        uploader.uploadProgress { progress in
            progressSubject.send(progress)
            if progress.isFinished || progress.isCancelled {
                progressSubject.send(completion: .finished)
            }
        }
        return .init(response: responsePublisher.eraseToAnyPublisher(),
                     progress: progressSubject.eraseToAnyPublisher())
    }
}

// MARK: - NetworkInformant + Concurrency
private extension NetworkInformant {
    
    /// Логировать описание запроса
    /// - Parameter request: Запрос
    func log(request: Alamofire.Request) {
        request.onURLRequestCreation { [weak self] request in
            self?.log(request: request)
        }
    }
}
#endif
