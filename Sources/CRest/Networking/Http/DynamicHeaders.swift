//
//  DynamicHeaders.swift
//

import Foundation

/// Ключи параметров загловках
public protocol HeaderKeys: RawRepresentable, Hashable where RawValue == String {}

/// Любой билдер загловк
public protocol AnyHeadersBuilder: AnyObject {

    func build() -> [String: String]
}

// MARK: - Http
public extension Http {

    /// Http загловки
    enum Headers {
        
        /// Создает и возвращает `Headers.Builder`
        /// - Parameter keys: Тип ключей
        /// - Returns: `Headers.Builder`
        public static func keyed<Keys>(by keys: Keys.Type) -> Builder<Keys> where Keys: HeaderKeys {
            .init(keyedBy: keys)
        }
        
        /// Тип значения
        public typealias Value = String

        /// Билдер
        public final class Builder<Key>: AnyHeadersBuilder where Key: HeaderKeys {

            /// загловки
            private var source = [String: String]()

            /// Инициализация
            /// - Parameter keyedBy: Тип ключей
            public init(keyedBy: Key.Type) {}

            /// Добавить значение под ключом
            /// - Parameters:
            ///   - value: значение
            ///   - key: ключ
            public func with(value: Value, for key: Key) -> Self {
                source[key.rawValue] = value
                return self
            }

            /// Создает загловки
            public func build() -> [String: String] {
                source
            }
        }
    }
}
