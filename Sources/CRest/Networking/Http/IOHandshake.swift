//
//  IOHandshake.swift
//

import Foundation

/// Протокол создания рукопожатия
public protocol IOHandshake: AnyObject, IOInterceptor {
    
    /// Запрос рукопожатия
    var handshakeRequest: Request { get }
    
    /// Код ошибки вызывающий повторного рукопожатия
    var handshakeStatusCodes: [Int] { get }
}

/// Сессия рукопожатия
public protocol HandshakeSession: Equatable {
    
    /// Идентификатор сессии
    var id: String { get }
    
    /// Ключ хедера
    var headerKey: String { get }
}

// MARK: - HandshakeSession + Default
public extension HandshakeSession {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

/// Протокол создателя рукопожатия
public protocol HandshakeSessionProvider: Sendable {
    
    /// Сессия рукопожатия
    var session: any HandshakeSession { get }
    
    /// Проверить, является ли используемые учетные данные корректные
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func isValidated(credential: any HandshakeSession) -> Bool
    
    /// Проверить, совпадают ли используемые учетные данные с данными в хранилище приложения.
    /// - Parameter credential: Учетные данные аутентификатора
    /// - Returns: Учетные данные из хранилища приложения nil если совпадают
    func match(_ credential: any HandshakeSession) throws -> (any HandshakeSession)?
    
    /// Создать сессию рукопожатия
    /// - Returns: `HandshakeSession`
    @discardableResult
    func handshake() async throws -> any HandshakeSession
}

/// Протокол авторизации на уровне рукопожатия
public protocol IOHandshakeAuthenticator: Sendable, IOHandshake {
    
    /// Провайдер рукопожатия
    var provider: HandshakeSessionProvider { get }
}
