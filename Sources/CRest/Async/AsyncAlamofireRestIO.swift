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
        let sessionConfiguration = configuration.sessionConfiguration ?? URLSessionConfiguration.af.default
        sessionConfiguration.httpCookieStorage = configuration.cookieStorage
        sessionConfiguration.httpShouldSetCookies = configuration.cookieStorage != nil
        sessionConfiguration.urlCredentialStorage = configuration.credentialStorage ?? URLCredentialStorage.shared
        self.session = Session(configuration: sessionConfiguration,
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
    
    // MARK: - Public
    
    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) async throws -> Response where Response: CRest.Response {
        try await dynamicPerform(request, response: response).response
    }
    
    public func dynamicPerform<Response>(_ request: DynamicRequest,
                                         response: Response.Type) async throws -> DynamicResponse<Response> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        let response = await requester
            .serializingResponse(using: ResponseSerializerWrapper<Response>(request))
            .response
        configuration.logger.debug(response)
        switch response.result {
        case let .success(model):
            return .init(model, response.response)
        case let .failure(error):
            throw error.reason(with: response.response?.statusCode, responseData: response.data)
        }
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type,
                                   progress: ProgressHandler?) async throws -> Response where Response: CRest.Response {
        let downloader = IO.with(session).downloadRequest(for: request, into: destination)
        invoke(progress, from: downloader.downloadProgress())
        let downloadResponse = await downloader
            .serializingDownload(using: ResponseSerializerWrapper<Response>(request))
            .response
        configuration.logger.debug(downloadResponse)
        switch downloadResponse.result {
        case .success(let model):
            return model
        case .failure(let error):
            throw error.reason(with: downloadResponse.response?.statusCode)
        }
    }
    
    public func upload<Response>(from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type,
                                 progress: ProgressHandler?) async throws -> Response where Response: CRest.Response {
        let uploader = IO.with(session).uploadRequest(for: request, from: source)
        invoke(progress, from: uploader.uploadProgress())
        let uploadResponse = await uploader
            .serializingResponse(using: ResponseSerializerWrapper<Response>(request))
            .response
        configuration.logger.debug(uploadResponse)
        switch uploadResponse.result {
        case .success(let model):
            return model
        case .failure(let error):
            throw error.reason(with: uploadResponse.response?.statusCode)
        }
    }
    
    // MARK: - Private
    
    /// Вызвать прогресс загрузки из асинхронного стрима
    /// - Parameters:
    ///   - progress: Обработчик прогресса
    ///   - stream: Стрим загрузки
    private func invoke(_ progress: ProgressHandler?, from stream: StreamOf<Progress>) {
        guard let progress else { return }
        Task {
            for await current in stream {
                progress(current)
            }
        }
    }
}
#endif
