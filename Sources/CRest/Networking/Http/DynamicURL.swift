//
//  DynamicURL.swift
//

import Foundation

/// Ключи параметров по ссылке
public protocol URLQueryKeys: RawRepresentable, Hashable where RawValue == String {}

// MARK: - DynamicURL

/// Динамическая REST ссылка
@frozen public struct DynamicURL {
    
    /// Билдер ссылки
    public final class Builder<Key> where Key: URLQueryKeys {

        /// базовый ссылка
        private var url: URL?
        /// Компоненты ссылки
        private var items = [URLQueryItem]()

        /// Инициализация
        /// - Parameter keyedBy: Тип ключей
        public init(keyedBy: Key.Type) {}

        /// Добавить базовую ссылку
        /// - Parameter url: Базовая ссылка
        public func with(base url: String) -> Self {
            self.url = URL(string: url)
            return self
        }

        /// Добавить базовую ссылку `EndPoint`
        /// - Parameter endPoint: Базовая ссылка
        public func with(endPoint: EndPoint) -> Self {
            self.url = URL(string: endPoint.rawValue)
            return self
        }

        /// Добавляет компонент пути к URL.
        /// - Parameter pathComponent: Компонент пути для добавления.
        public func with(pathComponent: Any) -> Self {
            self.url?.appendPathComponent(.init(describing: pathComponent).unicodeEncodedString)
            return self
        }

        /// Добавить значение под ключом
        /// - Parameters:
        ///   - value: значение
        ///   - key: ключ значения
        public func with(value: Value?, key: Key) -> Self {
            guard let value else { return self }
            items.append(.init(name: .init(describing: key.rawValue), value: .init(describing: value).unicodeEncodedString))
            return self
        }
        
        /// Добавить значение под ключом
        /// - Parameters:
        ///   - value: массив значения
        ///   - key: ключ значения
        public func with(values: [Value], key: Key) -> Self {
            guard !values.isEmpty else { return self }
            values.forEach { items.append(.init(name: .init(describing: key.rawValue), value: .init(describing: $0).unicodeEncodedString)) }
            return self
        }
        
        /// Добавить новый параметр с ключом используя `URLQueryItem`
        /// - Parameter query: Новый пармер
        public func with(_ query: URLQueryItem) -> Self {
            guard let value = query.value?.unicodeEncodedString else { return self }
            items.append(.init(name: query.name, value: value))
            return self
        }

        /// Создает ссылку
        public func build() -> DynamicURL {
            guard
                let url = url
            else { preconditionFailure("The Base URL is Nil, you must call with(base:) method befor call build") }
            guard
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else { preconditionFailure("The url components of \(url) is nil") }
            if !items.isEmpty {
                components.queryItems = items
            }
            guard
                let queryURL = components.url
            else { preconditionFailure("URL of components is nil \(components)") }
            return .init(queryURL)
        }
    }
    
    /// Создает и возвращает `DynamicURL.Builder`
    /// - Parameter keys: Тип ключей
    /// - Returns: `DynamicURL.Builder`
    public static func keyed<Keys>(by keys: Keys.Type) -> Builder<Keys> where Keys: URLQueryKeys {
        .init(keyedBy: keys)
    }
    
    /// Тип занчения
    public typealias Value = Any
    
    /// Ссылка запроса
    private let queryURL: URL

    /// Строковая значения ссылки
    public var row: String {
        queryURL.absoluteString
    }

    /// Абсолютная значения ссылки
    public var absolute: URL {
        queryURL
    }
    
    /// Инициализация
    /// - Parameter queryURL: Ссылка запроса
    public init(_ queryURL: URL) {
        self.queryURL = queryURL
    }
}

// MARK: - DynamicURL + ExpressibleByStringLiteral
extension DynamicURL: ExpressibleByStringLiteral {

    public typealias StringLiteralType = String

    public init(stringLiteral value: DynamicURL.StringLiteralType) {
        guard let url = URL(string: value) else { preconditionFailure("The URL is Nil, use build") }
        queryURL = url
    }
}

// MARK: - DynamicURL + CustomStringConvertible
extension DynamicURL: CustomStringConvertible {

    public var description: String { row }
}

// MARK: - DynamicURL + CustomLogStringConvertible
extension DynamicURL: CustomLogStringConvertible {

    public var logDescription: String { row }
}
