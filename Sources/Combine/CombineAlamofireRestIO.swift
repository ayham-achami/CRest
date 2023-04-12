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
                    self?.configuration.informant.logError(response: response)
                    throw error.reason(with: response.response?.statusCode, responseData: response.data)
                }
            }.eraseToAnyPublisher()
    }
    
    public func perform<Response>(_ request: DynamicRequest,
                                  response: Response.Type) -> AnyPublisher<DynamicResponse<Response>, Error> where Response: CRest.Response {
        let requester = IO.with(session).dataRequest(for: request)
        configuration.informant.log(request: requester)
        return requester.publishResponse(using: ResponseSerializerWrapper<Response>(request))
            .tryMap { [weak self] response in
                switch response.result {
                case let .success(model):
                    self?.configuration.informant.log(response: response)
                    return .init(model, response.response)
                case let .failure(error):
                    self?.configuration.informant.logError(response: response)
                    throw error.reason(with: response.response?.statusCode, responseData: response.data)
                }
            }.eraseToAnyPublisher()
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
                    self?.configuration.informant.logError(response: response)
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
                    self?.configuration.informant.logError(response: response)
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
