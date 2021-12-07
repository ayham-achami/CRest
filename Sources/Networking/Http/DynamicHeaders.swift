//
//  DynamicHeaders.swift
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

/// Ключи параметров загловках
public protocol HeaderKeys {}

/// Любой билдер загловк
public protocol AnyHeadersBuilder: AnyObject {

    func build() -> [String: String]
}

// MARK: - Http
public extension Http {

    /// Http загловки
    enum Headers {
        
        public enum DefaultKeys: String, HeaderKeys {
            case `default` = ""
        }
        
        public static var empty: Http.Headers.Builder<DefaultKeys> {
            Http.Headers.Builder(keyedBy: DefaultKeys.self)
        }

        /// Тип значения
        public typealias Value = String
        /// Тип ключей
        public typealias Key = HeaderKeys & RawRepresentable & Hashable

        /// Билдер
        public final class Builder<Key: Headers.Key>: AnyHeadersBuilder {

            /// загловки
            private var source = [String: String]()

            /// Инициализация
            /// - Parameter keyedBy: Тип ключей
            public init(keyedBy: Key.Type) {}

            /// Добавить значение под ключем
            /// - Parameters:
            ///   - value: значение
            ///   - key: ключ
            public func with(value: Value, for key: Key) -> Self {
                source[String(describing: key.rawValue)] = value
                return self
            }

            /// Создает загловки
            public func build() -> [String: String] {
                source
            }
        }
    }
}
