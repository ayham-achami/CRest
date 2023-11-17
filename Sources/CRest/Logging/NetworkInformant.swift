//
//  NetworkInformant.swift
//

import CFoundation
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

// Объект реализующий логирование Network клиента
public final class NetworkInformant {

    private let logger: Logger
    private let tag = "Network"

    public init(logger: Logger) {
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
        logger.json(data, file, function, line)
    }

    public func log(debug message: @autoclosure () -> Any,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.debug(message(), file, function, line)
    }

    public func log(error message: @autoclosure () -> Any,
                    _ file: StaticString = #file,
                    _ function: StaticString = #function,
                    _ line: Int = #line) {
        logger.error(message(), file, function, line)
    }
}
