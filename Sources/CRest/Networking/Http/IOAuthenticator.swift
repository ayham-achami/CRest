//
//  IOAuthenticator.swift
//

import Foundation

/// Протокол контроля статус авторизации
public protocol IOAuthenticator: IOInterceptor {
    
    /// Запрос обновления
    var refreshRequest: Request { get }
    
    /// Кода ошибок требующие повторной авторизации
    var refreshStatusCodes: [Int] { get }
}

/// Авторизации по BearerToken
public protocol BearerCredential {
    
    /// Токен
    var access: String { get }
    
    /// Валидный ли токен 
    var isValidated: Bool { get }
}

/// Учетные данные аутентификации
public protocol BearerCredentialProvider: Sendable {
    
    /// Учетные данные аутентификации
    var credential: BearerCredential { get }
    
    /// Запрос обновления учетных данных аутентификации
    /// - Returns: `BearerCredential`
    func refresh() async throws -> BearerCredential
}

/// Протокол контроля статус авторизации по BearerToken
public protocol IOBearerAuthenticator: Sendable, IOAuthenticator {
    
    /// Провайдер авторизации
    var provider: BearerCredentialProvider { get }
}
