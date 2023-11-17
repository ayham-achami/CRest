//
//  RestIOConfiguration.swift
//

import Foundation

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
}

// MARK: - RestIOConfiguration + Default
public extension RestIOConfiguration {

    var sessionConfiguration: URLSessionConfiguration? { nil }

    var trustEvaluating: TrustEvaluating? { nil }
}
