//
//  DynamicURL.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Community Arch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

/// Ключи параметров по ссылке
public protocol URLQueryKey {}

// MARK: - DynamicURL

/// Динамическая REST ссылка
public struct DynamicURL {

    /// Тип занчения
    public typealias Value = Any
    /// Тип ключей
    public typealias Key = URLQueryKey & RawRepresentable
    
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

    public init(_ queryURL: URL) {
        self.queryURL = queryURL
    }

    /// Билдер ссылки
    public final class Builder<KeyType: Key> {

        /// базовый ссылка
        private var url: URL?
        /// Компоненты ссылки
        private var items = [URLQueryItem]()

        /// Инициализация
        /// - Parameter keyedBy: Тип ключей
        public init(keyedBy: KeyType.Type) {}

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
        public func with(pathComponent: String) -> Self {
            self.url?.appendPathComponent(pathComponent)
            return self
        }

        /// Добавить значение под ключом
        /// - Parameters:
        ///   - value: значение
        ///   - key: ключ значения
        public func with(value: Value?, key: KeyType) -> Self {
            guard let value = value else { return self }
            items.append(URLQueryItem(name: String(describing: key.rawValue), value: "\(value)"))
            return self
        }

        /// Создает ссылку
        public func build() -> DynamicURL {
            guard let url = url else {
                fatalError("The Base URL is Nil, you must call with(base:) method befor call build")
            }
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                fatalError("The url components of \(url) is nil")
            }
            components.queryItems = items
            guard let queryURL = components.url else {
                fatalError("URL of components is nil \(components)")
            }
            return DynamicURL(queryURL)
        }
    }
}

// MARK: - DynamicURL + ExpressibleByStringLiteral
extension DynamicURL: ExpressibleByStringLiteral {

    public typealias StringLiteralType = String

    public init(stringLiteral value: DynamicURL.StringLiteralType) {
        guard let url = URL(string: value) else { fatalError("The URL is Nil, use build") }
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
