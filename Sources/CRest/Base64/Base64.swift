//
//  Base64.swift
//

import Foundation

/// Ошибка сериализации и десериализации
public enum Base64Error: Error {
    
    /// Ошибка сериализации
    case encoding
    /// Ошибка десериализации
    case decoding
}

/// Десериализации с Base64
public protocol Base64Decodable: Base64JSONDecoder {}

/// Сериализации с Base64
public protocol Base64Encodable: Base64JSONEncoder {}

/// Десериализации и сериализации с Base64
public typealias Base64Codable = Base64Decodable & Base64Encodable

// MARK: - KeyedDecodingContainer + Base64
public extension KeyedDecodingContainer {
    
    func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: Base64Decodable, T: Decodable {
        let string = try decode(String.self, forKey: key)
        guard
            let base64 = Data(base64Encoded: string, options: [])
        else { throw Base64Error.decoding }
        return try T.decoder.decode(T.self, from: base64)
    }
}

// MARK: - KeyedEncodingContainer + Base64
public extension KeyedEncodingContainer {
    
    mutating func encode<T>(_ object: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: Base64Encodable, T: Encodable {
        let base64 = try T.encoder.encode(object).base64EncodedString()
        try encode(base64, forKey: key)
    }
}
