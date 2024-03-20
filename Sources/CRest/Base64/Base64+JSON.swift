//
//  Base64+JSON.swift
//

import Foundation

/// Объект, который декодирует экземпляры типа Base64 данных из объектов JSON.
public protocol Base64JSONDecoder {
    
    /// Декодер
    static var decoder: JSONDecoder {  get }
}

// MARK: - Base64JSONDecoder + Default
public extension Base64JSONDecoder {
    
    static var decoder: JSONDecoder {  .init() }
}

/// Объект, который кодирует экземпляры типа Base64 данных как объекты JSON.
public protocol Base64JSONEncoder {
    
    /// Инкодер
    static var encoder: JSONEncoder {  get }
}

// MARK: - Base64JSONEncoder + Default
public extension Base64JSONEncoder {
    
    static var encoder: JSONEncoder {  .init() }
}
