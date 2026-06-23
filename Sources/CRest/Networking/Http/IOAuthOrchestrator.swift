//
//  IOAuthOrchestrator.swift
//

/// Стратегия авторизации
public enum AuthStrategy {
    
    case bearer
    case cookie
}

/// Протокол оркестратора авторизации
public protocol IOAuthOrchestrator: Sendable {
    
    /// Получить стратегию авторизации
    func strategy() -> AuthStrategy
}
