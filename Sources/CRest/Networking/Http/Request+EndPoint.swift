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
public extension CharacterSet {
    
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
 public extension String {
     
     /// Возвращает экранированные символы URL
     var unicodeEncodedString: String {
         unicodeEncodedString(with: .urlAllowedCharacters)
     }
     
     /// Возвращает экранированные символы URL
     /// - Parameter allowedCharacters: Допустимые символы хотя бы в одной части URL-адреса.
     /// - Returns: Экранированные символы URL
     func unicodeEncodedString(with allowedCharacters: CharacterSet) -> String {
         guard
             let unicodeEncodedString = removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
         else { preconditionFailure("Content unencoding character") }
         return unicodeEncodedString
     }
 }

/// REST запрос
@frozen public struct Request: Sendable, Hashable {
    
    public let rawValue: String
    
    /// Инициализация
    /// - Parameter dynamicURL: Динамический запрос
    public init(_ dynamicURL: DynamicURL) {
        self.rawValue = dynamicURL.row
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
