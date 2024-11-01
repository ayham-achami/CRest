//
//  AF+Trust.swift
//

#if compiler(>=5.6.0) && canImport(_Concurrency)
import Alamofire
import Foundation

/// Имплементация RestIO с Alamofire
public final class AsyncAlamofireRestIO: AsyncRestIO {

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
        let networkQueue = DispatchQueue(label: "RestIO.concurrency.networkQueue.\(id)", qos: .default)
        let requestsQueue = DispatchQueue(label: "RestIO.concurrency.requestsQueue.\(id)", qos: .default, attributes: .concurrent, target: networkQueue)
        let serializationQueue = DispatchQueue(label: "RestIO.concurrency.serializationQueue.\(id)", qos: .default, attributes: .concurrent, target: networkQueue)
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
                                  response: Response.Type) async throws(NetworkError) -> Response where Response: CRest.Response {
        try await dynamicPerform(request, response: response).response
    }
    
    public func dynamicPerform<Response>(_ request: DynamicRequest,
                                         response: Response.Type) async throws(NetworkError) -> DynamicResponse<Response> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        configuration.informant.log(request: requester)
        let response = await requester
            .serializingResponse(using: ResponseSerializerWrapper<Response>(request))
            .response
        switch response.result {
        case let .success(model):
            configuration.informant.log(response: response)
            return .init(model, response.response)
        case let .failure(error):
            configuration.informant.log(error: error)
            configuration.informant.logError(response: response)
            throw error.reason(with: response.response?.statusCode, responseData: response.data)
        }
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type,
                                   progress: (@Sendable (Progress) -> Void)?) async throws(NetworkError) -> Response where Response: CRest.Response {
        let downloader = IO.with(session).downloadRequest(for: request, into: destination)
        configuration.informant.log(request: downloader)
        invoke(progress, from: downloader.downloadProgress())
        let downloadResponse = await downloader
            .serializingDownload(using: ResponseSerializerWrapper<Response>(request))
            .response
        switch downloadResponse.result {
        case .success(let model):
            configuration.informant.log(response: downloadResponse)
            return model
        case .failure(let error):
            configuration.informant.log(error: error)
            configuration.informant.logError(response: downloadResponse)
            throw error.reason(with: downloadResponse.response?.statusCode)
        }
    }
    
    public func upload<Response>(from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type,
                                 progress: (@Sendable (Progress) -> Void)?) async throws(NetworkError) -> Response where Response: CRest.Response {
        let uploader = IO.with(session).uploadRequest(for: request, from: source)
        configuration.informant.log(request: uploader)
        invoke(progress, from: uploader.uploadProgress())
        let uploadResponse = await uploader
            .serializingResponse(using: ResponseSerializerWrapper<Response>(request))
            .response
        switch uploadResponse.result {
        case .success(let model):
            configuration.informant.log(response: uploadResponse)
            return model
        case .failure(let error):
            configuration.informant.log(error: error)
            configuration.informant.logError(response: uploadResponse)
            throw error.reason(with: uploadResponse.response?.statusCode)
        }
    }
}

// MARK: - AsyncAlamofireRestIO + Private
extension AsyncAlamofireRestIO {
    
    /// Вызвать прогресс загрузки из асинхронного стрима
    /// - Parameters:
    ///   - progress: Обработчик прогресса
    ///   - stream: Стрим загрузки
    func invoke(_ progress: (@Sendable (Progress) -> Void)?, from stream: sending StreamOf<Progress>) {
        guard let progress else { return }
        Task {
            for await current in stream {
                progress(current)
            }
        }
    }
}

// MARK: - NetworkInformant + Concurrency
private extension NetworkInformant {
    
    /// Логировать описание запроса из асинхронного стрима
    /// - Parameter request: Запрос
    func log(request: Alamofire.Request) {
        Task {
            for await request in request.urlRequests() {
                log(request: request)
            }
        }
    }
}
#endif
