//
//  Request+EndPoint.swift
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

/// Базовая ссылка
@frozen public struct EndPoint: Hashable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARk: - CharacterSet + URLAllowedCharacters
private extension CharacterSet {
    
    /// Допустимые символы хотя бы в одной части URL-адреса.
    /// Эти символы нельзя использовать во ВСЕХ частях URL-адреса
    /// у каждой части разные требования. Этот набор полезен для проверки
    /// символов Юникода, которые необходимо закодировать в процентах перед
    /// выполнением проверки достоверности отдельных компонентов URL.
    static var urlAllowedCharacters: CharacterSet {
        var characters = CharacterSet(charactersIn: "#")
        characters.formUnion(.urlUserAllowed)
        characters.formUnion(.urlPasswordAllowed)
        characters.formUnion(.urlHostAllowed)
        characters.formUnion(.urlPathAllowed)
        characters.formUnion(.urlQueryAllowed)
        characters.formUnion(.urlFragmentAllowed)
        return characters
    }
}

// MARK: - String + UnicodeEncodedString
private extension String {
    
    /// Возвращает экранированные символы URL
    var unicodeEncodedString: String {
        guard 
            let unicodeEncodedString = self
                .removingPercentEncoding?
                .addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters) 
        else { preconditionFailure("Content unencoding character") }
        return unicodeEncodedString
    }
}

/// REST запрос
@frozen public struct Request: Hashable {
    
    public let rawValue: String
    
    /// Инициализация
    /// - Parameters:
    ///   - endPoint: `endPoint`
    ///   - path: Путь запроса
    public init(endPoint: EndPoint, path: String) {
        self.rawValue = "\(endPoint.rawValue)\(path)".unicodeEncodedString
    }
    
    /// Инициализация
    /// - Parameter dynamicURL: Динамический запрос
    public init(_ dynamicURL: DynamicURL) {
        self.rawValue = dynamicURL.row.unicodeEncodedString
    }
}

// MARK: - Request + Equatable + URLRequest
public extension Request {
     
    /// Сравнить Request и URLRequest
    /// - Parameters:
    ///   - lhs: `URLRequest`
    ///   - rhs: `Request`
    /// - Returns: true если равны
    static func == (lhs: URLRequest, rhs: Self) -> Bool {
        lhs.url?.absoluteString ?? "" == rhs.rawValue
    }
    
    ///  Сравнить Request и URLRequest
    /// - Parameters:
    ///   - lhs: `URLRequest`
    ///   - rhs: `Request`
    /// - Returns: true если не равны
    static func != (lhs: URLRequest, rhs: Self) -> Bool {
        !(lhs == rhs)
    }
}
