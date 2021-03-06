//
//  Multipart.swift
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

#if canImport(UIKit)
import UIKit
#endif
import Foundation

/// Любой параметр в автомате multipart
public protocol MultipartParameter {}

/// Мультипартпараметр содержащий любые данные
public struct DataMultipartParameter: MultipartParameter {

    /// Данные для отправки
    public let data: Data
    /// Ключи данных в наборе
    public let name: String

    /// Добавить данные
    ///
    /// - Parameters:
    ///   - value: Данные
    ///   - key: Ключ
    public init(_ data: Data, _ name: String) {
        self.data = data
        self.name = name
    }

    /// инициализировать с сериализуемым объектом
    /// - Parameters:
    ///   - value: Сериализуемый объект
    ///   - key: Ключ
    public init<Value>(_ value: Value, _ name: String) throws where Value: Parameters {
        self.data = try JSONEncoder().encode(value)
        self.name = name
    }

    /// инициализировать со славорем
    ///
    /// - Parameters:
    ///   - value: словарь (JSON)
    ///   - key: ключ
    /// - Throws: MultipartFormDataSerializationError если ну удалось сериализовать
    public init(_ dictionary: [String: Any], _ name: String) throws {
        self.data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        self.name = name
    }

    /// добавить строку
    ///
    /// - Parameters:
    ///   - value: строка
    ///   - key: ключ
    public init(_ value: String, _ name: String, _ encoding: String.Encoding = .utf8) throws {
        guard let data = value.data(using: encoding) else { throw SerializationError(String.self) }
        self.data = data
        self.name = name
    }
}

#if canImport(UIKit)
/// Мультипартпараметр содержащий картинку
public struct ImageMultipartParameter: MultipartParameter {

    public let data: Data
    public let name: String
    public let mime: String

    public init(_ image: UIImage, _ name: String, _ serialization: UIImage.Serialization = .png) throws {
        self.data = try image.serialized(serialization)
        self.name = name
        self.mime = "image/\(serialization.rawValue)"
    }
}
#endif

/// Стримить данные в Multipart
public struct StreamMultipartParameter: MultipartParameter {

    public let url: URL
    public let name: String

    public init(_ url: URL, _ name: String) {
        self.url = url
        self.name = name
    }
}

/// Парметры в мульти типовых
public struct MultipartParameters: Parameters {

    private var content: [MultipartParameter] = []

    public init() {}

    public init(_ initail: (MultipartParameters) -> Void) {
        initail(self)
    }

    /// Добавить парметр
    /// - Parameter parameter: Парметр
    public mutating func append(_ parameter: MultipartParameter) {
        content.append(parameter)
    }

    /// вызывает данное замыкание для каждого элемента в последовательности
    /// - Parameter body: (мультипарт параметр)
    public func forEach(_ body: (MultipartParameter) throws -> Void) rethrows {
        try content.forEach { try body($0) }
    }

    /// Мапить параметры
    /// - Parameter body: (мультипарт параметр)
    public func map<T>(_ body: (MultipartParameter) throws -> T) rethrows -> [T] {
        try content.map { try body($0) }
    }

    /// Stub methods don't use
    /// - Parameter encoder: _
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("MultipartParameters couldn't to be encoding")
    }
}

// MARK: - реализация по умолчанию
extension MultipartParameters {

    public var description: String {
        content.description
    }

    public var debugDescription: String {
        content.debugDescription
    }
}
