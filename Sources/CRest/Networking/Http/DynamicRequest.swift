//
//  DynamicRequest.swift
//

import Foundation

/// Динамический http запрос
@frozen public struct DynamicRequest {

    /// Урль запроса
    public let url: String
    /// Проверяет имеет ли ответ код в допустимом диапазоне по умолчанию 200...299
    public let validate: Bool
    /// Метод запроса
    public let method: Http.Method
    /// Объект десерлизации
    public let decoder: JSONDecoder
    /// Объект сериализации
    public let encoder: JSONEncoder
    /// Параметры запроса
    public let parameters: Parameters?
    /// Тип енкодинга
    public let encoding: Http.Encoding
    /// Загловки
    public let headers: [String: String]
    /// Серилизатор ответа
    public let serializer: IOSerializer
    /// Наблюдатели запроса
    public let interceptors: [IOInterceptor]
    /// http коды с которыми разрешено пустой ответ
    public let emptyResponseCodes: Set<Int>
    /// http методы с которыми разрешено пустой ответ
    public let emptyRequestMethods: Set<Http.Method>

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
        private var serializer: IOSerializer = DefaultSerializer()
        private var interceptors: [IOInterceptor] = [DefaultInterceptor()]
        private var emptyResponseCodes: Set<Int> = [204]
        private var emptyRequestMethods: Set<Http.Method> = [.head]
        
        /// Инициализация
        /// - Parameter parameters: Прпметры запроса
        public init(parameters: Parameters? = nil) {
            self.parameters = nil
        }
        
        /// Добвить URL
        /// - Parameter url: урль
        public func with(url: String) -> Self {
            self.url = url
            return self
        }
        
        /// Добавить проверку имеет ли ответ код в допустимом диапазоне по умолчанию 200...299
        /// - Parameter validate: Флаг
        public func with(validate: Bool) -> Self {
            self.validate = validate
            return self
        }
        
        /// Добавить REST запрос
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
        
        /// Добавить параметры
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
        
        /// Добавить объект десерлизации
        /// - Parameter decoder: Объект десерлизации
        public func with(decoder: JSONDecoder) -> Self {
            self.decoder = decoder
            return self
        }
        
        /// Добавить объект сериализации
        /// - Parameter encoder: Обеъкт серлизации
        public func with(encoder: JSONEncoder) -> Self {
            self.encoder = encoder
            return self
        }
        
        /// Добавить сериализтор ответа
        /// - Parameter serializer: Сериализтор ответа
        public func with(serializer: IOSerializer) -> Self {
            self.serializer = serializer
            return self
        }
        
        ///  Добавить наблюдатели запрса
        /// - Parameter interceptor: наблюдатели запрса
        public func with(interceptors: [IOInterceptor]) -> Self {
            self.interceptors = interceptors
            return self
        }
        
        public func with(emptyResponseCodes: Set<Int>) -> Self {
            self.emptyResponseCodes = emptyResponseCodes
            return self
        }
        
        public func with(emptyRequestMethods: Set<Http.Method>) -> Self {
            self.emptyRequestMethods = emptyRequestMethods
            return self
        }
        
        /// Создает запрос
        public func build() throws -> DynamicRequest {
            guard
                let url = url
            else { throw ModelBuildError(errorDescription: "Dynamic request URL is nil") }
            return .init(url: url,
                         validate: validate,
                         method: method,
                         decoder: decoder,
                         encoder: encoder,
                         parameters: parameters,
                         encoding: encoding,
                         headers: headers,
                         serializer: serializer,
                         interceptors: interceptors,
                         emptyResponseCodes: emptyResponseCodes,
                         emptyRequestMethods: emptyRequestMethods)
        }
    }
}
