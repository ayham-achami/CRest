//
//  ProgressPublisher.swift
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

import Foundation
import Alamofire

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
    /// - Returns: `UploadRequest`
    func uploadRequest(for request: DynamicRequest, from source: URL) -> UploadRequest {
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
