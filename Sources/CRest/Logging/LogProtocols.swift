//
//  LogProtocols.swift
//

import Foundation

/// тип с настраиваемым текстовым представлением для логирования
public protocol CustomLogStringConvertible {

    /// преобразование в строку для логирования
    var logDescription: String { get }
}

/// протокол преобразования запроса в CURL
public protocol CustomCURLStringConvertible {

    /// CURL значения запроса
    var curl: String { get }
}

// MARK: - URLRequest + CustomCURLStringConvertible
extension URLRequest: CustomCURLStringConvertible {

    public var curl: String {
        var components = ["$ curl -v"]
        guard let url = url else { return "$ curl command could not be created" }
        if let httpMethod = httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }
        if let allHeaders = allHTTPHeaderFields {
            let headers = allHeaders.map { "-H \"\($0.key): \($0.value.replacingOccurrences(of: "\"", with: "\\\""))\"" }
            components.append(contentsOf: headers)
        }
        if let data = httpBody {
            let body = String(decoding: data, as: UTF8.self)
            var escapedBody = body.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-d \"\(escapedBody)\"")
        }
        components.append("\"\(url.absoluteString)\"")
        return components.joined(separator: " \\\n\t")
    }
}

// MARK: - URLRequest + RequestLog
extension URLRequest: RequestLog {

    public var requestDescription: String {
        debugDescription
    }
}

// MARK: - URLResponse + ResponseLog
extension URLResponse: ResponseLog {

    public var responseDescription: String {
        debugDescription
    }

    public var curl: String {
        "$ curl command could not be created"
    }
}
