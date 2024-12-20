//
//  RestLogger.swift
//

import Alamofire
import Foundation

/// Логгер
public protocol RestLoggerProtocol: Sendable {
    
    /// Логирование запроса на уровне дебаг
    /// - Parameters:
    ///   - log: Данные лога
    ///   - configuration: Конфигурация
    func debug(_ log: RestLog, with configuration: LoggerConfiguration)
}

/// Логирование сетевых ответов
public protocol RestLog: CustomCURLStringConvertible {
    
    /// Метрики запроса
    var transactionMetrics: URLSessionTaskTransactionMetrics? { get }
    
    /// Запрос
    var request: URLRequest? { get }
    
    /// Ответ
    var response: HTTPURLResponse? { get }
    
    /// Возвращаемые данные
    var data: Data? { get }
    
    /// Описание ответа
    var responseDescription: String { get }
}

/// Конфигурация логгера
public struct LoggerConfiguration {
    
    /// Инициатор логирования
    public let initiator: String
    /// Флаг необходимости очистить тело запроса
    public let shouldSanitazedBody: Bool
    
    public init(initiator: String, shouldSanitazedBody: Bool) {
        self.initiator = initiator
        self.shouldSanitazedBody = shouldSanitazedBody
    }
}

// Объект реализующий логирование сетевого клиента
public struct RestLogger: Sendable {

    private let logger: RestLoggerProtocol
    private let configuration: LoggerConfiguration

    public init(logger: RestLoggerProtocol,
                configuration: LoggerConfiguration) {
        self.logger = logger
        self.configuration = configuration
    }
    
    func debug(_ log: RestLog) {
        logger.debug(log, with: configuration)
    }
}
