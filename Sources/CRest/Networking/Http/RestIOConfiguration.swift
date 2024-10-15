//
//  RestIOConfiguration.swift
//

import Foundation

/// Поведение и логика кэширования данных запросов
public enum IOCacheBehavior: Sendable {
    
    /// Замыкание кастомизация кэширования
    /// Если данное замыкание возвращает nil данные не будет закэшированными
    public typealias Controller = @Sendable (URLSessionDataTask, CachedURLResponse) -> CachedURLResponse?

    /// Не кэшировать данные запросов
    case never
    /// Кэшировать данные запросов смотри `URLCache`
    case `default`
    /// Кастомное кеширование
    case costume(Controller)
}

/// Общие настройки REST клиента
public protocol RestIOConfiguration: Sendable {

    /// Объект конфигурации, который определяет поведение и политики для сеанса URL
    var sessionConfiguration: URLSessionConfiguration? { get }

    /// Объект реализующий логирование Network клиента
    var informant: NetworkInformant { get }
    
    /// Оценщик доверии к серверу
    var trustEvaluator: TrustEvaluator? { get }
    
    /// Оценщик доверии к серверу
    var trustEvaluating: TrustEvaluating? { get }
    
    /// Необходимо ли проверять все хосты на доверие
    var allHostsMustBeEvaluated: Bool { get }
    
    /// Поведение и логика кэширования данных запросов
    var cacheBehavior: IOCacheBehavior { get }
    
    /// Сессионный интерцептор
    var sessionInterceptor: IOSessionInterceptor? { get }
}

// MARK: - RestIOConfiguration + Default
public extension RestIOConfiguration {

    var sessionConfiguration: URLSessionConfiguration? { nil }

    var allHostsMustBeEvaluated: Bool { false }
    
    var trustEvaluator: TrustEvaluator? { nil }
    
    var trustEvaluating: TrustEvaluating? { nil }
    
    var cacheBehavior: IOCacheBehavior { .default }
    
    var sessionInterceptor: IOSessionInterceptor? { nil }
}

/// Создатель сессионного интерцептор
public enum RestIOSession {
    
    /// Возвращает сессионный интерцептор, интерцептор создается один раз при вызове функции, при 
    /// повторном вызове возвращается тоже объектов, что было создано до этого
    /// - Parameter bearer: Контроля статус авторизации по BearerToken
    /// - Returns: `IOSessionInterceptor`
    static public func interceptor(bearer: IOBearerAuthenticator) -> IOSessionInterceptor {
        if let bearerAuthentication {
            return bearerAuthentication
        } else {
            let bearerAuthentication = create(bearer: bearer)
            Self.bearerAuthentication = bearerAuthentication
            return bearerAuthentication
        }
    }
    
    /// Возвращает сессионный интерцептор, интерцептор создается один раз при вызове функции, при 
    /// повторном вызове возвращается тоже объектов, что было создано до этого
    /// - Parameter handshake: Авторизации на уровне рукопожатия
    /// - Returns: `IOHandshakeAuthenticator`
    static public func interceptor(handshake: IOHandshakeAuthenticator) -> IOSessionInterceptor {
        if let handshakeAuthentication {
            return handshakeAuthentication
        } else {
            let handshakeAuthentication = create(handshake: handshake)
            Self.handshakeAuthentication = handshakeAuthentication
            return handshakeAuthentication
        }
    }
}
