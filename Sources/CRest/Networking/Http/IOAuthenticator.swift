//
//  IOAuthenticator.swift
//

import Foundation

/// Протокол контроля статус авторизации
public protocol IOAuthenticator: AnyObject, IOInterceptor {
    
    /// Запрос обновления
    var refreshRequest: Request { get }
    
    /// Кода ошибок требующие повторной авторизации
    var refreshStatusCodes: [Int] { get }
}

/// Авторизации по BearerToken
public protocol BearerCredential: Equatable {
    
    /// Токен
    var access: String { get }
    
    /// Валидный ли токен 
    var isValidated: Bool { get }
}

public extension BearerCredential {
 
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.access == rhs.access
    }
}

/// Учетные данные аутентификации
public protocol BearerCredentialProvider: Sendable {
    
    /// Учетные данные аутентификации
    var credential: any BearerCredential { get }
    
    /// Проверить, является ли используемые учетные данные корректные
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func isValidated(credential: any BearerCredential) -> Bool
    
    /// Проверить, совпадают ли используемые учетные данные с данными в хранилище приложения.
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func match(_ credential: any BearerCredential) throws -> (any BearerCredential)?
    
    /// Запрос обновления учетных данных аутентификации
    /// - Returns: `BearerCredential`
    func refresh() async throws -> any BearerCredential
}

/// Протокол контроля статус авторизации по BearerToken
public protocol IOBearerAuthenticator: Sendable, IOAuthenticator {
    
    /// Провайдер авторизации
    var provider: BearerCredentialProvider { get }
}
