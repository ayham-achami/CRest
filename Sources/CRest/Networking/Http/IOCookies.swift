//
//  IOCookies.swift
//

import Foundation

/// Авторизации по Cookies
public protocol CookiesCredential: Sendable {
    
    var cookies: [HTTPCookie] { get }
}

/// Учетные данные аутентификации
public protocol CookiesCredentialProvider: Sendable {
    
    /// Хранилище Cookies
    var storage: HTTPCookieStorage { get }
    
    /// Учетные данные аутентификации
    var credential: any CookiesCredential { get }
    
    /// Проверить, является ли используемые учетные данные корректные
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func isValidated(credential: any CookiesCredential) -> Bool
    
    /// Запрос обновления учетных данных аутентификации
    /// - Returns: `BearerCredential`
    func refresh() async throws -> any CookiesCredential
}

/// Протокол контроля статус авторизации по Cookies
public protocol IOCookiesAuthenticator: Sendable, IOAuthenticator {
    
    /// Провайдер Cookies
    var provider: CookiesCredentialProvider { get }
}
