//
//  JSONRepresentable.swift
//

import Foundation

/// Протокол представления JSON
public protocol JSONRepresentable {
    
    /// Получить значение по ключ в JSON
    subscript<Base>(key: String, type: Base.Type) -> Base? { get }
}

// MARK: - JSONRepresentable + Baseable
public extension JSONRepresentable where Self: Baseable {
    
    subscript<Base>(key: String, type: Base.Type) -> Base? {
        guard
            let json = base as? [String: Any],
            let value = json[key] as? Base
        else { return nil }
        return value
    }
}
