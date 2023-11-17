//
//  GZip+Base64.swift
//

import Foundation

/// Десериализации с Base64 c GZip
public protocol Base64GZipDecodable: Base64JSONDecoder {}

/// Сериализации с Base64 c GZip
public protocol Base64GZipEncodable: Base64JSONEncoder {}

/// Десериализации и сериализации с Base64 c GZip
public typealias Base64GZipCodable = Base64GZipDecodable & Base64GZipEncodable

// MARK: - KeyedDecodingContainer + Base64 c GZip
public extension KeyedDecodingContainer {
    
    func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: Base64GZipDecodable, T: Decodable {
        let string = try decode(String.self, forKey: key)
        guard
            let base64 = try Data(base64Encoded: string, options: [])?.gunzipped()
        else { throw Base64Error.decoding }
        return try T.decoder.decode(T.self, from: base64)
    }
}

// MARK: - KeyedEncodingContainer + Base64 c GZip
public extension KeyedEncodingContainer {
    
    mutating func encode<T>(_ object: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: Base64GZipEncodable, T: Encodable {
        let base64 = try T.encoder.encode(object).gzipped().base64EncodedString()
        try encode(base64, forKey: key)
    }
}
