//
//  NetworkInformant.swift
//

import Alamofire
import Foundation

/// Логгер
public protocol RestLogger: Sendable {
    
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

/// Логирование сетевых запросов
public protocol RequestLog: CustomCURLStringConvertible {

    /// Описание запроса
    var requestDescription: String { get }
}

/// Логирование сетевых ответов
public protocol ResponseLog: CustomCURLStringConvertible {

    /// Описание ответа
    var responseDescription: String { get }
}

/// логирования
public protocol NetworkLogger: Sendable {
    
    /// Вывод сообщения уровня дибаг
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func debug(with tag: String, _ message: @autoclosure () -> Any, _ file: StaticString, _ function: StaticString, _ line: Int)
    
    /// Вывод сообщения уровня ошбики
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func error(with tag: String, _ message: @autoclosure () -> Any, _ file: StaticString, _ function: StaticString, _ line: Int)
    
    /// Вывод JSON уровня информации дибаг
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - data: `Data` JSON
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func json(with tag: String, _ data: Data, _ file: StaticString, _ function: StaticString, _ line: Int)
}

// Объект реализующий логирование Network клиента
public final class NetworkInformant: Sendable {

    private let initiator: String
    private let logger: RestLogger
    private let shouldSanitazedBody: Bool

    public init(initiator: String,
                logger: RestLogger,
                shouldSanitazedBody: Bool) {
        self.logger = logger
        self.initiator = initiator
        self.shouldSanitazedBody = shouldSanitazedBody
    }
    
    func log(_ restLog: RestLog) {
        logger.log(restLog, with: shouldSanitazedBody, from: initiator)
    }
}
