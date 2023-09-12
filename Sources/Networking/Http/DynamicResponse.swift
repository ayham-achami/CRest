//
//  DynamicResponse.swift
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

/// Динамический ответ
@frozen public struct DynamicResponse<Response: CRest.Response> {
    
    /// Состояние ответа
    public enum State {
        
        /// Ошибочный
        case invalid(Response)
        /// Успешный
        case actually(DynamicResponse<Response>)
    }
    
    /// URL запроса
    public let url: URL?
    /// Код ответа
    public let statusCode: Int
    /// Ответ
    public let response: Response
    /// Загловки ответа
    public let allHeaderFields: [AnyHashable: Any]
    
    /// Состояние ответа
    public var state: State {
        guard url != nil else { return .invalid(response) }
        return .actually(self)
    }
    
    /// Инициализация
    /// - Parameters:
    ///   - response: Ответ
    ///   - URLResponse: URL ответ
    public init(_ response: Response, _ URLResponse: HTTPURLResponse?) {
        self.response = response
        if let URLResponse = URLResponse {
            url = URLResponse.url
            statusCode = URLResponse.statusCode
            allHeaderFields = URLResponse.allHeaderFields
        } else {
            url = nil
            statusCode = -1
            allHeaderFields = [:]
        }
    }
}
