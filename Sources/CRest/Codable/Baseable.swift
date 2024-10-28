//
//  Baseable.swift
//

import Foundation

/// Протокол базовых объектов
public protocol Baseable {
    
    /// Базовый объект
    var base: Sendable { get }
    
    /// Инициализация
    /// - Parameter base: Базовый объект
    init<Base>(_ base: Base?)
}
