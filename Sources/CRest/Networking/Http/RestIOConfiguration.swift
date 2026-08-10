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
    
    /// Хранилище учетных данных
    var credentialStorage: URLCredentialStorage? { get }
    
    /// Хранилище для кук, используемое в REST-клиенте
    var cookieStorage: HTTPCookieStorage? { get }

    /// Объект реализующий логирование сетевого клиента
    var logger: RestLogger { get }
    
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
    
    var credentialStorage: URLCredentialStorage? { nil }
    
    var cookieStorage: HTTPCookieStorage? { nil }

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
    /// - Parameter bearer: Контроля статус авторизации по BearerToken
    /// - Returns: `IOSessionInterceptor`
    static public func secondaryInterceptor(bearer: IOBearerAuthenticator) -> IOSessionInterceptor {
        if let secondaryBearerAuthentication {
            return secondaryBearerAuthentication
        } else {
            let secondaryBearerAuthentication = create(bearer: bearer)
            Self.secondaryBearerAuthentication = secondaryBearerAuthentication
            return secondaryBearerAuthentication
        }
    }
    
    /// Возвращает сессионный интерцептор, интерцептор создается один раз при вызове функции, при
    /// повторном вызове возвращается тоже объектов, что было создано до этого
    /// - Parameter bearer: Контроля статус авторизации по Cookie
    /// - Returns: `IOSessionInterceptor`
    static public func interceptor(cookies: IOCookiesAuthenticator) -> IOSessionInterceptor {
        if let cookiesAuthentication {
            return cookiesAuthentication
        } else {
            let cookiesAuthentication = create(cookies: cookies)
            Self.cookiesAuthentication = cookiesAuthentication
            return cookiesAuthentication
        }
    }
    
    /// Возвращает сессионный интерцептор, интерцептор создается один раз при вызове функции, при
    /// повторном вызове возвращает тот же объект, что был создан до этого
    /// - Parameters:
    ///   - orchestrator: Оркестратор авторизации
    ///   - bearer: Аутентификатор использующий BearerToken
    ///   - cookies: Аутентификатор использующий Cookies
    /// - Returns: `IOSessionInterceptor`
    static public func interceptor(orchestrator: IOAuthOrchestrator,
                                   bearer: IOBearerAuthenticator,
                                   cookies: IOCookiesAuthenticator) -> IOSessionInterceptor {
        if let authStrategyAuthentication {
            return authStrategyAuthentication
        } else {
            let authStrategyAuthentication = create(orchestrator: orchestrator, bearer: bearer, cookies: cookies)
            Self.authStrategyAuthentication = authStrategyAuthentication
            return authStrategyAuthentication
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
