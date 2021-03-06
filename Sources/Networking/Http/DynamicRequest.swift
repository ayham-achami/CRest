//
//  DynamicRequest.swift
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

/// Динамический http запрос
public struct DynamicRequest {

    /// Урль запроса
    public let url: String
    /// Проверяет имеет ли ответ код в допустимом диапазоне по умолчанию 200...299
    public let validate: Bool
    /// Метод запроса
    public let method: Http.Method
    /// Обеъкт десерлизации
    public let decoder: JSONDecoder
    /// Объект сериализации
    public let encoder: JSONEncoder
    /// Параметры запрса
    public let parameters: Parameters?
    /// Тип енкодинга
    public let encoding: Http.Encoding
    /// Загловки
    public let headers: [String: String]
    /// Наблюдатель запрса
    public let interceptor: RestInterceptor

    /// Билдер
    public final class Builder {

        private var url: String?
        private var validate: Bool = true
        private var parameters: Parameters?
        private var method: Http.Method = .get
        private var encoding: Http.Encoding = .JSON
        private var headers: [String: String] = [:]
        private var decoder: JSONDecoder = JSONDecoder()
        private var encoder: JSONEncoder = JSONEncoder()
        private var interceptor: RestInterceptor = Http.Interceptor()

        /// Инициализация
        /// - Parameter parameters: Прпметры запроса
        public init(parameters: Parameters? = nil) {
            self.parameters = nil
        }

        /// Добваить урль
        /// - Parameter url: урль
        public func with(url: String) -> Self {
            self.url = url
            return self
        }
        
        /// Добавить провеку имеет ли ответ код в допустимом диапазоне по умолчанию 200...299
        /// - Parameter validate: Флаг
        public func with(validate: Bool) -> Self {
            self.validate = validate
            return self
        }

        /// Добваить рестовый запрос
        /// - Parameter request: Рестовый запрос
        public func with(request: Request) -> Self {
            self.url = request.rawValue
            return self
        }

        /// Добавить метод
        /// - Parameter method: метода `Http.Method`
        public func with(method: Http.Method) -> Self {
            self.method = method
            return self
        }

        /// Добавить парметры
        /// - Parameter parameters: парметры `Parameters`
        public func with(parameters: Parameters?) -> Self {
            self.parameters = parameters
            return self
        }

        /// Добавить тип енкодинга
        /// - Parameter encoding: Тип еникодинга  `Http.Encoding`
        public func with(encoding: Http.Encoding) -> Self {
            self.encoding = encoding
            return self
        }

        /// Добавить загловки
        /// - Parameter headers: Загловки
        public func with(headers: AnyHeadersBuilder) -> Self {
            self.headers = headers.build()
            return self
        }

        /// Добавить обеъкт десерлизации
        /// - Parameter decoder: Обеъкт десерлизации
        public func with(decoder: JSONDecoder) -> Self {
            self.decoder = decoder
            return self
        }

        /// Добавить обеъкт серлизации
        /// - Parameter encoder: Обеъкт серлизации
        public func with(encoder: JSONEncoder) -> Self {
            self.encoder = encoder
            return self
        }

        ///  Добавить наблюдатель запрса
        /// - Parameter interceptor: наблюдатель запрса
        public func with(interceptor: RestInterceptor) -> Self {
            self.interceptor = interceptor
            return self
        }

        /// Создает запрос
        public func build() throws -> DynamicRequest {
            guard let url = url else { throw ModelBuildError(errorDescription: "Dynamic request URL is nil") }
            return DynamicRequest(url: url,
                                  validate: validate,
                                  method: method,
                                  decoder: decoder,
                                  encoder: encoder,
                                  parameters: parameters,
                                  encoding: encoding,
                                  headers: headers,
                                  interceptor: interceptor)
        }
    }
}
