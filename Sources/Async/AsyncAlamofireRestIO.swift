//
//  AF+Trust.swift
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

#if compiler(>=5.6.0) && canImport(_Concurrency)
import Alamofire
import Foundation

/// Имплементация RestIO с Alamofire
public final class AsyncAlamofireRestIO: AsyncRestIO {
    
    // MARK: - Lazy
    
    /// Сессия запросов
    private lazy var session: Session = {
        .init(configuration: configuration.sessionConfiguration ?? URLSessionConfiguration.af.default,
              rootQueue: networkQueue,
              requestQueue: requestsQueue,
              serializationQueue: serializationQueue,
              serverTrustManager: configuration.serverTrustManager)
    }()
    
    /// Очередь запросов
    private lazy var networkQueue: DispatchQueue = {
        .init(label: "RestIO.concurrency.networkQueue", qos: .default)
    }()
    
    /// Очередь запросов
    private lazy var requestsQueue: DispatchQueue = {
        .init(label: "RestIO.concurrency.requestsQueue", qos: .default, attributes: .concurrent, target: networkQueue)
    }()
    
    /// Очередь десериализации
    private lazy var serializationQueue: DispatchQueue = {
        .init(label: "RestIO.concurrency.serializationQueue", qos: .default, attributes: .concurrent, target: networkQueue)
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
        try await dynamicPerform(request, response: response).response
    }
    
    public func dynamicPerform<Response>(_ request: DynamicRequest, response: Response.Type) async throws -> DynamicResponse<Response> where Response: CRest.Response {
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
            configuration.informant.logError(response: response)
            throw error.reason(with: response.response?.statusCode, responseData: response.data)
        }
    }
    
    public func download<Response>(into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type,
                                   progress: ProgressHandler?) async throws -> Response where Response: CRest.Response {
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
            configuration.informant.logError(response: downloadResponse)
            throw error.reason(with: downloadResponse.response?.statusCode)
        }
    }
    
    public func upload<Response>(from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type,
                                 progress: ProgressHandler?) async throws -> Response where Response: CRest.Response {
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
            configuration.informant.logError(response: uploadResponse)
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
