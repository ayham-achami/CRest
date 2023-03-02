//
//  AsyncAlamofireRestIO.swift
//  CFoundation
//
//  Created by Aleksandr Miaots on 15.11.2021.
//  Copyright © 2021 Cometrica. All rights reserved.
//

#if compiler(>=5.6.0) && canImport(_Concurrency)
import Alamofire
import Foundation

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
    
    // MARK: - Private properties
    
    private let configuration: RestIOConfiguration
    
    // MARK: - Init
    
    public init(_ configuration: RestIOConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Public
    
    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) async throws -> Response where Response: CRest.Response {
        let requester = dataRequest(for: request)
        configuration.informant.log(request: requester)
        let response = await requester
            .serializingResponse(using: IOResponseSerializer<Response>(request))
            .response
        switch response.result {
        case let .success(model):
            configuration.informant.log(response: response)
            return model
        case let .failure(error):
            configuration.informant.logError(response: response)
            throw reason(from: error, response.response?.statusCode, responseData: response.data)
        }
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type,
                                   progress: ProgressHandler?) async throws -> Response where Response: CRest.Response {
        let downloader = downloadRequest(for: request, into: destination)
        configuration.informant.log(request: downloader)
        invoke(progress, from: downloader.downloadProgress())
        let downloadResponse = await downloader
            .serializingDownload(using: IOResponseSerializer<Response>(request))
            .response
        switch downloadResponse.result {
        case .success(let model):
            configuration.informant.log(response: downloadResponse)
            return model
        case .failure(let error):
            configuration.informant.logError(response: downloadResponse)
            throw reason(from: error, downloadResponse.response?.statusCode)
        }
    }
    
    public func upload<Response>(from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type,
                                 progress: ProgressHandler?) async throws -> Response where Response: CRest.Response {
        let uploader = uploadRequest(for: request, from: source)
        configuration.informant.log(request: uploader)
        invoke(progress, from: uploader.uploadProgress())
        let uploadResponse = await uploader
            .serializingResponse(using: IOResponseSerializer<Response>(request))
            .response
        switch uploadResponse.result {
        case .success(let model):
            configuration.informant.log(response: uploadResponse)
            return model
        case .failure(let error):
            configuration.informant.logError(response: uploadResponse)
            throw reason(from: error, uploadResponse.response?.statusCode)
        }
    }
    
    /// <#Description#>
    /// - Parameter request: <#request description#>
    /// - Returns: <#description#>
    private func dataRequest(for request: DynamicRequest) -> DataRequest {
        switch request.encoding {
        case let .URL(configuration):
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: configuration.URLEncoded,
                                   headers: request.afHeders,
                                   interceptor: request.interceptor)
            .validate(request.validate)
            .retry(request.interceptor)
        case .JSON:
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: request.afJSONEncoder,
                                   headers: request.afHeders,
                                   interceptor: request.interceptor)
            .validate(request.validate)
            .retry(request.interceptor)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.interceptor)
            .validate(request.validate)
            .retry(request.interceptor)
        }
    }
    
    // MARK: - Private
    
    /// Возвращает запрос загрузки для заданного запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - destination: Ссылка куда сохранить загруженных данных
    private func downloadRequest(for request: DynamicRequest, into destination: Destination) -> DownloadRequest {
        let afDestination: DownloadRequest.Destination = { _, _ in (destination, [.removePreviousFile]) }
        switch request.encoding {
        case let .URL(configuration):
            return session.download(request.url,
                                    method: request.afMethod,
                                    parameters: request.afParameters,
                                    encoder: configuration.URLEncoded,
                                    headers: request.afHeders,
                                    interceptor: request.interceptor,
                                    to: afDestination)
            .validate(request.validate)
            .retry(request.interceptor)
        case .JSON:
            return session.download(request.url,
                                    method: request.afMethod,
                                    parameters: request.afParameters,
                                    encoder: JSONParameterEncoder.default,
                                    headers: request.afHeders,
                                    interceptor: request.interceptor,
                                    to: afDestination)
            .validate(request.validate)
            .retry(request.interceptor)
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
                                  interceptor: request.interceptor)
            .validate(request.validate)
            .retry(request.interceptor)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders,
                                  interceptor: request.interceptor)
            .validate(request.validate)
            .retry(request.interceptor)
        }
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - progress: <#progress description#>
    ///   - stream: <#stream description#>
    private func invoke(_ progress: ProgressHandler?, from stream: StreamOf<Progress>) {
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
    
    /// <#Description#>
    /// - Parameter request: <#request description#>
    func log(request: Alamofire.Request) {
        Task {
            for await request in request.urlRequests() {
                log(request: request)
            }
        }
    }
}
#endif
