//
//  RestIOConfiguration.swift
//

import Foundation

/// Поведение и логика кэширования данных запросов
public enum IOCacheBehavior {
    
    /// Замыкание кастомизация кэширования
    /// Если данное замыкание возвращает nil данные не будет закэшированными
    public typealias Controller = (URLSessionDataTask, CachedURLResponse) -> CachedURLResponse?

    /// Не кэшировать данные запросов
    case never
    /// Кэшировать данные запросов смотри `URLCache`
    case `default`
    /// Кастомнее кастомизацие
    case costume(Controller)
}

/// Общие настройки REST клиента
public protocol RestIOConfiguration {

    /// Объект конфигурации, который определяет поведение и политики для сеанса URL
    var sessionConfiguration: URLSessionConfiguration? { get }

    /// Объект реализующий логирование Network клиента
    var informant: NetworkInformant { get }

    /// Оценщик доверии к серверу
    var trustEvaluating: TrustEvaluating? { get }
    
    /// Необходимо ли проверять все хосты на доверие
    var allHostsMustBeEvaluated: Bool { get }
    
    /// Поведение и логика кэширования данных запросов
    var cacheBehavior: IOCacheBehavior { get }
}

// MARK: - RestIOConfiguration + Default
public extension RestIOConfiguration {

    var sessionConfiguration: URLSessionConfiguration? { nil }

    var trustEvaluating: TrustEvaluating? { nil }
    
    var cacheBehavior: IOCacheBehavior { .default }
}
