//
//  SerializationError.swift
//

import Foundation

/// Ошибка сериализации объекта
struct SerializationError<T>: LocalizedError {

    var errorDescription: String {
        "Serialization error %s".localized(args: String(describing: T.self))
    }
    
    /// Инициализация
    /// - Parameter type: Тип объекта
    init(_ type: T.Type) {}
}
