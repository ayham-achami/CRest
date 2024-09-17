//
//  ProgressPublisher.swift
//

import Alamofire
import Foundation

// swiftlint:disable:next type_name
struct IO {
    
    /// Создает и возвращает `IO` с заданной сессии
    /// - Parameter session: Сессия
    /// - Returns: `IO`
    static func with(_ session: Session) -> Self {
        .init(session)
    }
    
    /// Сессия
    private let session: Session
    
    /// Инициализация
    /// - Parameter session: Сессия
    init(_ session: Session) {
        self.session = session
    }
    
    /// Возвращает запрос загрузки байтов для заданного запроса
    /// - Parameter request: Динамический запрос
    /// - Returns: `DataRequest`
    func dataRequest(for request: DynamicRequest) -> DataRequest {
        switch request.encoding {
        case let .URL(configuration):
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: configuration.URLEncoded,
                                   headers: request.afHeders,
                                   interceptor: request.afInterceptor)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        case .JSON:
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: request.afJSONEncoder,
                                   headers: request.afHeders,
                                   interceptor: request.afInterceptor)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.afInterceptor)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        }
    }
    
    /// Возвращает запрос загрузки для заданного запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - destination: Ссылка куда сохранить загруженных данных
    /// - Returns: `DownloadRequest`
    func downloadRequest(for request: DynamicRequest, into destination: URL) -> DownloadRequest {
        let afDestination: DownloadRequest.Destination = { _, _ in (destination, [.removePreviousFile]) }
        switch request.encoding {
        case let .URL(configuration):
            return session.download(request.url,
                                    method: request.afMethod,
                                    parameters: request.afParameters,
                                    encoder: configuration.URLEncoded,
                                    headers: request.afHeders,
                                    interceptor: request.afInterceptor,
                                    to: afDestination)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        case .JSON:
            return session.download(request.url,
                                    method: request.afMethod,
                                    parameters: request.afParameters,
                                    encoder: JSONParameterEncoder.default,
                                    headers: request.afHeders,
                                    interceptor: request.afInterceptor,
                                    to: afDestination)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        case .multipart:
            preconditionFailure("Download request not support multipart parameters")
        }
    }
    
    /// Возвращает запрос выгрузки для заданного запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - source: Ссылка на источник данных
    /// - Returns: `UploadRequest`
    func uploadRequest(for request: DynamicRequest, from source: URL) -> UploadRequest {
        switch request.encoding {
        case .URL, .JSON:
            return session.upload(source,
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.afInterceptor)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.afInterceptor)
            .cacheResponse(with: request.cacheBehavior)
            .validate(request.validate)
        }
    }
}

// MARK: - Request + IOCachePolicy
private extension Alamofire.Request {
    
    func cacheResponse(with cacheBehavior: IOCacheBehavior?) -> Self {
        guard let cacheBehavior else { return self }
        cacheResponse(using: IOResponseCacher(behavior: cacheBehavior))
        return self
    }
}
