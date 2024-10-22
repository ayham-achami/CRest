//
//  Request+EndPoint.swift
//

import Foundation

/// Базовая ссылка
@frozen public struct EndPoint: Sendable, Hashable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - CharacterSet + URLAllowedCharacters
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
             let unicodeEncodedString = removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters)
         else { preconditionFailure("Content unencoding character") }
         return unicodeEncodedString
     }
 }

/// REST запрос
@frozen public struct Request: Sendable, Hashable {
    
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
