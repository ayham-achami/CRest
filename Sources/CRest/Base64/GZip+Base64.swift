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

/// Протокол для зжатии данных через zlib
public protocol Base64GZippier {
    
    /// Создайте новый объект Data, сжимая приемник с помощью zlib. Выдает ошибку, если сжатие не удалось.
    var zip: Data { get throws }
    
    /// Создайте новый объект Data, распаковав приемник с помощью zlib. Выдает ошибку, если распаковка не удалась.
    var unzip: Data { get throws }
    
    /// Инициализация
    /// - Parameter data: `Data`
    init(_ data: Data)
}

// MARK: - KeyedDecodingContainer + Base64 c GZip
public extension KeyedDecodingContainer {
    
    func decode<T, Z>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, using: Z.Type) throws -> T where T: Base64GZipDecodable, T: Decodable, Z: Base64GZippier {
        let string = try decode(String.self, forKey: key)
        guard
            let base64 = Data(base64Encoded: string, options: [])
        else { throw Base64Error.decoding }
        return try T.decoder.decode(T.self, from: try Z.init(base64).zip)
    }
}

// MARK: - KeyedEncodingContainer + Base64 c GZip
public extension KeyedEncodingContainer {
    
    mutating func encode<T, Z>(_ object: T, forKey key: KeyedEncodingContainer<K>.Key, using: Z.Type) throws where T: Base64GZipEncodable, T: Encodable, Z: Base64GZippier {
        let base64 = try Z.init(T.encoder.encode(object)).unzip.base64EncodedString()
        try encode(base64, forKey: key)
    }
}
