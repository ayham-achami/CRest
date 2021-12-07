//
//  CombineAlamofireRestIO.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Community Arch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#if canImport(Combine)
import Combine
import Alamofire
import Foundation

// MARK: - CombineAlamofireRestIO

/// Имплементация RestIO с Alamofire и Combine
@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
public final class CombineAlamofireRestIO: CombineRestIO {
    
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
        DispatchQueue(label: "ReactiveRestIO.Combine.networkQueue", qos: .default)
    }()
    
    /// Поток запросов
    private lazy var requestsQueue: DispatchQueue = {
        DispatchQueue(label: "ReactiveRestIO.Combine.requestsQueue", qos: .default, target: networkQueue)
    }()
    
    /// Поток сериализации
    private lazy var serializationQueue: DispatchQueue = {
        DispatchQueue(label: "ReactiveRestIO.Combine.serializationQueue", qos: .default, target: networkQueue)
    }()
    
    // MARK: - Private properties
    
    private let configuration: RestIOConfiguration
    
    // MARK: - Init
    
    public init(_ configuration: RestIOConfiguration) {
        self.configuration = configuration
    }
    
    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) -> AnyPublisher<Response, Error> where Response: CRest.Response {
        let dataRequest = self.dataRequest(for: request)
        configuration.informant.log(request: dataRequest)
        return dataRequest.response(of: response,
                                    queue: serializationQueue,
                                    decoder: request.decoder,
                                    interceptor: request.interceptor,
                                    informant: configuration.informant)
    }
    
    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) -> AnyPublisher<DynamicResponse<Response>, Error> where Response: CRest.Response {
        let dataRequest = self.dataRequest(for: request)
        configuration.informant.log(request: dataRequest)
        return dataRequest.response(of: response,
                                    queue: serializationQueue,
                                    decoder: request.decoder,
                                    interceptor: request.interceptor,
                                    informant: configuration.informant)
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        let downloader = downloadRequest(for: request, info: destination)
        configuration.informant.log(request: downloader)
        let responsePublisher = downloader
            .publishDecodable(type: response, decoder: request.decoder)
            .tryMap { [weak self] response -> Response in
                self?.configuration.informant.log(response: response)
                switch response.result {
                case let .success(model):
                    return model
                case let .failure(error):
                    throw reason(from: error, response.response?.statusCode)
                }
            }
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
        let uploader = uploadRequest(for: request, from: source)
        configuration.informant.log(request: uploader)
        let responsePublisher = uploader
            .publishDecodable(type: response, decoder: request.decoder)
            .tryMap { [weak self] response -> Response in
                self?.configuration.informant.log(response: response)
                switch response.result {
                case let .success(model):
                    return model
                case let .failure(error):
                    throw reason(from: error, response.response?.statusCode)
                }
            }
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
    
    /// Возвращает запрос данных для заданного запроса
    /// - Parameter request: Динамический запрос
    private func dataRequest(for request: DynamicRequest) -> DataRequest {
        switch request.encoding {
        case let .URL(configuration):
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: configuration.URLEncoded,
                                   headers: request.afHeders).validate(request.validate).retry(request.interceptor)
        case .JSON:
            return session.request(request.url,
                                   method: request.afMethod,
                                   parameters: request.afParameters,
                                   encoder: request.afJSONEncoder,
                                   headers: request.afHeders).validate(request.validate).retry(request.interceptor)
        case .multipart:
            return session.upload(multipartFormData: request.encode(into:),
                                  to: request.url,
                                  method: request.afMethod,
                                  headers: request.afHeders).validate(request.validate).retry(request.interceptor)
        }
    }
    
    /// Возвращает запрос загруски для заданного запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - destination: Ссылка куда сохранить загруженных данных
    private func downloadRequest(for request: DynamicRequest,
                                 info destination: Destination) -> DownloadRequest {
        let afDestination: DownloadRequest.Destination = { _, _ in (destination, [.removePreviousFile]) }
        switch request.encoding {
        case let .URL(configuration):
            return self.session.download(request.url,
                                         method: request.afMethod,
                                         parameters: request.afParameters,
                                         encoder: configuration.URLEncoded,
                                         headers: request.afHeders,
                                         to: afDestination)
                .validate(request.validate)
                .retry(request.interceptor)
        case .JSON:
            return self.session.download(request.url,
                                         method: request.afMethod,
                                         parameters: request.afParameters,
                                         encoder: JSONParameterEncoder.default,
                                         headers: request.afHeders,
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
    private func uploadRequest(for request: DynamicRequest,
                               from source: Source) -> UploadRequest {
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
}
#endif
