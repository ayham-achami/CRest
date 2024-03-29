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
@frozen public struct AdaptedRequest {
    
    /// Запрос
    public let request: URLRequest
    
    /// Добавить Хейдар
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
    
    /// Обновить тела запроса
    /// - Parameter httpBody: Тела запроса
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(_ httpBody: Data) -> Self {
        var request = self.request
        request.httpBody = httpBody
        return .init(request: request)
    }
    
    /// Обновить запрос
    /// - Parameter request: Новый запрос
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(_ request: URLRequest) -> Self {
        .init(request: request)
    }
    
    /// Обновить качество сервиса
    /// - Parameter service: Новое качество сервиса
    /// - Returns: `AdaptedRequest`
    @discardableResult
    public func set(_ service: URLRequest.NetworkServiceType) -> Self {
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
public protocol IORequestAdapter {
    
    /// Адаптация запроса
    /// - Parameter adapted: Адаптируемый запрос
    /// - Returns: `Result<AdaptedRequest, Error>`
    func adapt(_ adapted: AdaptedRequest) -> Result<AdaptedRequest, Error>
}

// MARK: - IORequestAdapter + Default
public extension IORequestAdapter {
    
    func adapt(_ adapted: AdaptedRequest) -> Result<AdaptedRequest, Error> {
        .success(adapted)
    }
}

/// Протокол адаптации запроса MultiPart
public protocol IORequestMultipartAdapter {
    
    /// Адаптация часть тела запроса
    /// - Parameter data: Часть тела запроса
    /// - Returns: `Data`
    func adapt(_ data: Data) -> Data
    
    /// Адаптация часть тела запроса по ссылки
    /// - Parameter url: Часть тела запроса по ссылки
    /// - Returns: `URL`
    func adapt(_ url: URL) -> URL
}

// MARK: - IORequestMultipartAdapter + Default
extension IORequestMultipartAdapter {
    
    public func adapt(_ data: Data) -> Data {
        data
    }
    
    public func adapt(_ url: URL) -> URL {
        url
    }
}

/// Протокол повторения запроса
public protocol IORequestRetrier {
    
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

/// Наблюдать за запросами по умолчанию
@frozen public struct DefaultInterceptor: IOInterceptor {}
