//
//  LogProtocols.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Community Arch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
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
