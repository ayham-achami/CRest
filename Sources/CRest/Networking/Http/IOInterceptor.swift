//
//  IOInterceptor.swift
//

import Foundation

/// Повторить ли запрос 
public enum IORetry {

    /// Не повторять попытку
    case omit
    /// Повторять попытка немедленно
    case retry
    /// Не повторять попытку передавая новую ошибку
    case drop(Error)
    /// Повторять попытку после `TimeInterval`
    case delay(TimeInterval)
}

/// Адаптируемый запрос
@frozen public struct AdaptedRequest: Sendable {
    
    /// Запрос
    public let request: URLRequest
    
    /// Инициализация
    /// - Parameter request: `URLRequest`
    public init(request: URLRequest) {
        self.request = request
    }
    
    /// Добавить хейдар
    /// - Parameters:
    ///   - header: Ключ хейдара
    ///   - field: Значение хейдара
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func append(header: String, field: String) -> Self {
        var request = self.request
        request.addValue(header, forHTTPHeaderField: field)
        return .init(request: request)
    }
    
    /// Добавить хейдар
    /// - Parameter headers: Словарь с закладками
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func append(headers: [String: String]) -> Self {
        var request = self.request
        headers.forEach { field, header in request.addValue(header, forHTTPHeaderField: field) }
        return .init(request: request)
    }
    
    /// Обновить хейдер
    /// - Parameters:
    ///   - header: Ключ хейдара
    ///   - field: Значение хейдара
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(header: String, field: String) -> Self {
        var request = self.request
        request.setValue(header, forHTTPHeaderField: field)
        return .init(request: request)
    }
 
    /// Обновить хейдер
    /// - Parameters:
    ///   - headers: Словарь с закладками
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(headers: [String: String]) -> Self {
        var request = self.request
        headers.forEach { field, header in request.setValue(header, forHTTPHeaderField: field) }
        return .init(request: request)
    }
    
    /// Обновить URL запроса
    /// - Parameter url: Новый URL
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(url: URL) -> Self {
        var request = self.request
        request.url = url
        return .init(request: request)
    }
    
    /// Обновить тела запроса
    /// - Parameter httpBody: Тела запроса
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(httpBody: Data?) -> Self {
        var request = self.request
        request.httpBody = httpBody
        return .init(request: request)
    }
    
    /// Обновить запрос
    /// - Parameter request: Новый запрос
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(request: URLRequest) -> Self {
        .init(request: request)
    }
    
    /// Обновить качество сервиса
    /// - Parameter service: Новое качество сервиса
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(service: URLRequest.NetworkServiceType) -> Self {
        var request = self.request
        request.networkServiceType = service
        return .init(request: request)
    }
    
    /// Обновить запрос
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func adapt() -> Self {
        .init(request: request)
    }
}

/// Протокол адаптации запроса
public protocol IORequestAdapter: Sendable {
    
    /// Адаптация запроса асинхронный вызывает обработчик завершения с результатом.
    /// - Parameters:
    ///   - adapted: Адаптируемый запрос
    ///   - completion: Обработчик завершения
    func adapt(_ adapted: AdaptedRequest, completion: @Sendable @escaping (Result<AdaptedRequest, Error>) -> Void)
}

// MARK: - IORequestAdapter + Default
public extension IORequestAdapter {
    
    func adapt(_ adapted: AdaptedRequest, completion: @Sendable @escaping (Result<AdaptedRequest, Error>) -> Void) {
        completion(.success(adapted))
    }
}

/// Протокол адаптации запроса MultiPart
public protocol IORequestMultipartAdapter: Sendable {
    
    /// Адаптация часть тела запроса
    /// - Parameter data: Часть тела запроса
    /// - Parameter completion: Обработчик завершения
    func adapt(_ data: Data, completion: @Sendable @escaping (Result<Data, Error>) -> Void)
    
    /// Адаптация часть тела запроса по ссылки
    /// - Parameter url: Часть тела запроса по ссылки
    /// - Parameter completion: Обработчик завершения
    func adapt(_ url: URL, completion: @Sendable @escaping (Result<URL, Error>) -> Void)
}

// MARK: - IORequestMultipartAdapter + Default
public extension IORequestMultipartAdapter {
    
    func adapt(_ data: Data, completion: @Sendable @escaping (Result<Data, Error>) -> Void) {
        completion(.success(data))
    }
    
    func adapt(_ url: URL, completion: @Sendable @escaping (Result<URL, Error>) -> Void) {
        completion(.success(url))
    }
}

/// Протокол повторения запроса
public protocol IORequestRetrier: Sendable {
    
    /// Получить решение о повторении запроса
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Ответ
    ///   - retryCount: Количества повторения
    ///   - error: Ошибка
    /// - Returns: `IORetry`
    func retry(_ request: URLRequest, _ response: HTTPURLResponse, _ retryCount: Int, dueTo error: Error) -> IORetry
}

// MARK: - IORequestRetrier + Default
public extension IORequestRetrier {
    
    func retry(_ request: URLRequest, _ response: HTTPURLResponse, _ retryCount: Int, dueTo error: Error) -> IORetry {
        .omit
    }
}

/// Протокол модификации запроса
public protocol IOInterceptor: IORequestAdapter, IORequestRetrier {}

/// Перехватчик по умолчанию
@frozen public struct DefaultInterceptor: IOInterceptor {
    
    public init() {}
}
