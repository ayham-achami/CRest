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
public protocol BearerCredential {
    
    /// Токен
    var access: String { get }
    
    /// Валидный ли токен 
    var isValidated: Bool { get }
}

/// Учетные данные аутентификации
public protocol BearerCredentialProvider {
    
    /// Учетные данные аутентификации
    var credential: BearerCredential { get }
    
    /// Запрос обновления учетных данных аутентификации
    /// - Returns: `BearerCredential`
    @discardableResult
    func refresh() async throws -> BearerCredential
}

/// Протокол контроля статус авторизации по BearerToken
public protocol IOBearerAuthenticator: IOAuthenticator {
    
    /// Провайдер авторизации
    var provider: BearerCredentialProvider { get }
}
