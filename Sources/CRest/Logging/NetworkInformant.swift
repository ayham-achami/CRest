//
//  NetworkInformant.swift
//

import Foundation

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

    private let tag = "Network"
    private let logger: NetworkLogger

    public init(logger: NetworkLogger) {
        self.logger = logger
    }

    public func log(request: RequestLog,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.debug(with: tag, """
        Sending request {
            Description: \n\t\(request.requestDescription)
            CURL: \n\t\(request.curl)
        }
        """, file, function, line)
    }

    public func log(response: ResponseLog,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.debug(with: tag, """
        Received response {
            Description: \n\t\(response.responseDescription)
            CURL: \n\t\(response.curl)

        }
        """, file, function, line)
    }
    
    public func logError(response: ResponseLog,
                         _ file: StaticString = #file,
                         _ function: StaticString = #function,
                         _ line: Int = #line) {
        logger.error(with: tag, """
        Received response {
            Description: \n\t\(response.responseDescription)
            CURL: \n\t\(response.curl)
        
        }
        """, file, function, line)
    }

    public func cancel(request: RequestLog,
                       _ file: StaticString = #file,
                       _ function: StaticString = #function,
                       _ line: Int = #line) {
        logger.debug(with: tag, """
        Cancel request {
            Description: \n\t\(request.requestDescription)
            CURL: \n\t\(request.curl)
        }
        """, file, function, line)
    }
    
    public func log(json data: Data,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.json(with: "JSONDebug", data, file, function, line)
    }

    public func log(debug message: @autoclosure () -> Any,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.debug(with: "Debug", message(), file, function, line)
    }

    public func log(error message: @autoclosure () -> Any,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.error(with: "Error", message(), file, function, line)
    }
}
