//
//  AsyncAlamofireRestIO.swift
//  CFoundation
//
//  Created by Aleksandr Miaots on 15.11.2021.
//  Copyright © 2021 Cometrica. All rights reserved.
//

#if compiler(>=5.5.2) && canImport(_Concurrency)

import Alamofire

// MARK: - AlamofireRestIO

/// Имплементация RestIO с Alamofire
@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
public final class AsyncAlamofireRestIO: AsyncRestIO {
    
    // MARK: - Lazy

    /// Сессия запросов
    private lazy var session: Session = {
        Session(configuration: configuration.sessionConfiguration ?? URLSessionConfiguration.af.default,
                rootQueue: networkQueue,
                requestQueue: requestsQueue,
                serverTrustManager: configuration.serverTrustManager)
    }()

    /// Поток запросов
    private lazy var networkQueue: DispatchQueue = {
        DispatchQueue(label: "RestIO.networkQueue", qos: .default)
    }()

    /// Поток запросов
    private lazy var requestsQueue: DispatchQueue = {
        DispatchQueue(label: "RestIO.requestsQueue", qos: .default, target: networkQueue)
    }()

    /// Поток стерилизации
    private lazy var serializationQueue: DispatchQueue = {
        DispatchQueue(label: "RestIO.serializationQueue", qos: .default, target: networkQueue)
    }()

    // MARK: - Private properties

    private let configuration: RestIOConfiguration

    // MARK: - Init

    public init(_ configuration: RestIOConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Public

    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) async throws -> Response where Response: CRest.Response {
        try await dataRequest(for: request)
            .serializingDecodable(response, decoder: request.decoder)
            .value
    }
    
    private func dataRequest(for request: DynamicRequest) async throws -> DataRequest {
        switch request.encoding {
        case let .URL(configuration):
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: configuration.URLEncoded,
                                   headers: request.afHeders,
                                   interceptor: request.interceptor).validate(request.validate).retry(request.interceptor)
        case .JSON:
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: request.afJSONEncoder,
                                   headers: request.afHeders,
                                   interceptor: request.interceptor).validate(request.validate).retry(request.interceptor)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.interceptor).validate(request.validate).retry(request.interceptor)
        }
    }
    
    public func download<Owner, Response>(for owner: Owner,
                                          into destination: Destination,
                                          with request: DynamicRequest,
                                          response: Response.Type) -> ProgressToken<Owner, Response> where Owner: AnyObject, Response: CRest.Response {
        let observer = ProgressObserver(owner: owner, argumentType: response)
        let downloader = downloadRequest(for: request, info: destination)
        configuration.informant.log(request: downloader)
        downloader.downloadProgress { [weak observer] progress in
            observer?.invoke(progress)
        }.responseData(queue: .main) { [weak observer, weak self] response in
            self?.configuration.informant.log(response: response)
            switch response.result {
            case .success(let data):
                if let model = try? request.decoder.decode(Response.self, from: data) {
                    observer?.invoke(model)
                } else {
                    observer?.invoke(NetworkError.parsing(data))
                }
            case .failure(let error):
                observer?.invoke(reason(from: error, response.response?.statusCode, responseData: response.resumeData))
            }
        }
        return ProgressToken(observer, downloader)
    }

    public func upload<Owner, Response>(for owner: Owner,
                                        from source: Source,
                                        with request: DynamicRequest,
                                        response: Response.Type) -> ProgressToken<Owner, Response> where Owner: AnyObject,
                                                                                                         Response: CRest.Response {
        let observer = ProgressObserver(owner: owner, argumentType: response)
        let uploader = uploadRequest(for: request, from: source)
        configuration.informant.log(request: uploader)
        let token = ProgressToken(observer, uploader)
        uploader.uploadProgress { [weak observer] progress in
            observer?.invoke(progress)
        }.responseDecodable(of: response, queue: serializationQueue, decoder: request.decoder) { [weak observer, weak self] response in
            self?.configuration.informant.log(response: response)
            switch response.result {
            case .success(let model):
                observer?.invoke(model)
            case .failure(let error):
                observer?.invoke(reason(from: error, response.response?.statusCode, responseData: response.data))
            }
        }
        return token
    }

    /// Возвращает запрос загруски для заданного запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - destination: Ссылка куда сохранить загруженных данных
    private func downloadRequest(for request: DynamicRequest, info destination: Destination) -> DownloadRequest {
        let afDestination: DownloadRequest.Destination = { _, _ in (destination, [.removePreviousFile]) }
        switch request.encoding {
        case let .URL(configuration):
            return session.download(request.url,
                                    method: request.afMethod,
                                    parameters: request.afParameters,
                                    encoder: configuration.URLEncoded,
                                    headers: request.afHeders,
                                    interceptor: request.interceptor,
                                    to: afDestination).validate(request.validate).retry(request.interceptor)
        case .JSON:
            return session.download(request.url,
                                    method: request.afMethod,
                                    parameters: request.afParameters,
                                    encoder: JSONParameterEncoder.default,
                                    headers: request.afHeders,
                                    interceptor: request.interceptor,
                                    to: afDestination).validate(request.validate).retry(request.interceptor)
        case .multipart:
            preconditionFailure("Download request not support multipart parameters")
        }
    }

    /// Возвращает запрос выгрузки для заданного запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - source: Ссылка на источник данных
    private func uploadRequest(for request: DynamicRequest, from source: Source) -> UploadRequest {
        switch request.encoding {
        case .URL, .JSON:
            return session.upload(source,
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.interceptor).validate(request.validate).retry(request.interceptor)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.interceptor).validate(request.validate).retry(request.interceptor)
        }
    }

    private func upload(with request: DynamicRequest) -> UploadRequest {
        session.upload(multipartFormData: request.encode(into:), to: request.url, method: request.afMethod, headers: request.afHeders)
    }
}
#endif
