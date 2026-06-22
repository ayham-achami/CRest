//
//  IOCookies.swift
//

import Foundation

/// Протокол контроля статус авторизации
public protocol IOPathsAuthenticator: AnyObject, IOInterceptor {
    
    /// Пути для обновлений
    var refreshPaths: [String] { get }
    
    /// Кода ошибок требующие повторной авторизации
    var refreshStatusCodes: [Int] { get }
}

/// Авторизации по Cookies
public protocol CookiesCredential: Sendable {
    
    var cookies: [HTTPCookie] { get }
}

/// Учетные данные аутентификации
public protocol CookiesCredentialProvider: Sendable {
    
    /// Учетные данные аутентификации
    var credential: any CookiesCredential { get }
    
    /// Проверить, является ли используемые учетные данные корректные
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func isValidated(credential: any CookiesCredential) -> Bool
    
    /// Запрос обновления учетных данных аутентификации
    /// - Returns: `CookiesCredential`
    func refresh() async throws -> any CookiesCredential
    
    /// Проверить, совпадают ли используемые учетные данные с данными в хранилище приложения.
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func match(_ credential: any CookiesCredential) throws -> (any CookiesCredential)?
    
    /// Определяет, аутентифицирован ли URLRequest с помощью учетных данных
    /// - Parameters:
    ///   - urlRequest: URLRequest
    ///   - credential: Учетные данные
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: CookiesCredential) -> Bool
}

/// Протокол контроля статус авторизации по Cookies
public protocol IOCookiesAuthenticator: Sendable, IOPathsAuthenticator {
    
    /// Провайдер Cookies
    var provider: CookiesCredentialProvider { get }
}
