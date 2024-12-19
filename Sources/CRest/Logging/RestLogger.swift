//
//  RestLogger.swift
//

import Alamofire
import Foundation

/// Логгер
public protocol RestLoggerProtocol: Sendable {
    
    func log(_ restLog: RestLog, with shouldSanitazedBody: Bool, from initiator: String)
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

// Объект реализующий логирование сетевого клиента
public struct RestLogger: Sendable {

    private let initiator: String
    private let logger: RestLoggerProtocol
    private let shouldSanitazedBody: Bool

    public init(initiator: String,
                logger: RestLoggerProtocol,
                shouldSanitazedBody: Bool) {
        self.logger = logger
        self.initiator = initiator
        self.shouldSanitazedBody = shouldSanitazedBody
    }
    
    func log(_ restLog: RestLog) {
        logger.log(restLog, with: shouldSanitazedBody, from: initiator)
    }
}
