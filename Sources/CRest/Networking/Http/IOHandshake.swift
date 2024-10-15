//
//  IOHandshake.swift
//

import Foundation

/// Протокол создания рукопожатия
public protocol IOHandshake: IOInterceptor {
    
    /// Запрос рукопожатия
    var handshakeRequest: Request { get }
    
    /// Код ошибки вызывающий повторного рукопожатия
    var handshakeStatusCodes: [Int] { get }
}

/// Сессия рукопожатия
public protocol HandshakeSession {
    
    /// Идентификатор сессии
    var id: String { get }
    
    /// Ключ хедера
    var headerKey: String { get }
    
    /// Валидная ли текущая сессия
    var isValidated: Bool { get }
}

/// Протокол создателя рукопожатия
public protocol HandshakeSessionProvider: Sendable {
    
    /// Сессия рукопожатия
    var session: HandshakeSession { get }
    
    /// Создать сессию рукопожатия
    /// - Returns: `HandshakeSession`
    @discardableResult
    func handshake() async throws -> HandshakeSession
}

/// Протокол авторизации на уровне рукопожатия
public protocol IOHandshakeAuthenticator: Sendable, IOHandshake {
    
    /// Провайдер рукопожатия
    var provider: HandshakeSessionProvider { get }
}
