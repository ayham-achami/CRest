//
//  Models.swift
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
import CFoundation

/// Любой ответ любого запроса
public typealias Response = Model & Decodable

/// Любые параметры любого запроса
public typealias Parameters = Model & Encodable

/// Любые параметры/ответ любого запроса
public typealias UniversalModel = Model & Codable

/// Любой ответ любого запроса в виде массива
public typealias CollectionResponse = Response & CollectionRepresented

/// Любые параметры любого запроса в виде массива
public typealias CollectionParameters = Parameters & CollectionRepresented

/// Протокол представления объекта модели в виде массива
public protocol CollectionRepresented: Collection {

    /// Тип элемента массива
    associatedtype Item: Any

    /// Массив объектов модели
    var list: [Item] { get }
}

// MARK: - CollectionRepresented + Model
extension CollectionRepresented where Item: Model, Index == Int {

    public var startIndex: Int {
        list.startIndex
    }

    public var endIndex: Int {
        list.endIndex
    }

    public func index(after i: Int) -> Int {
        list.index(after: i)
    }

    public subscript(_ index: Index) -> Item {
        list[index]
    }
}

/// Протокол реализующий логику парсинга дефолтное значение для `Enum`
public protocol RawResponse: Response, RawRepresentable {

    /// Дефолтное значение
    static var `default`: Self { get }

    /// Инициализация с помощью первоначального значения
    /// если значение не известное возвращается дефолтное значение
    /// - Parameter rawValue: Значение первоначальное
    init(try rawValue: RawValue)
}

// MARK: - RawResponse + Default
public extension RawResponse {

    init(try rawValue: RawValue) {
        if let result = Self.init(rawValue: rawValue) {
            self = result
        } else {
            self = .default
        }
    }

    init?(_ rawValueOrNil: RawValue?) {
        guard let rawValueOrNil = rawValueOrNil else { return nil }
        self.init(rawValue: rawValueOrNil)
    }
}

// MARK: - RawResponse + Response
public extension RawResponse where RawValue: Response {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        if let result = Self.init(rawValue: rawValue) {
            self = result
        } else {
            self = .default
        }
    }
}

/// Протокол создание объекта модели через билдер
public protocol ParametersBuilder: AnyObject {

    /// Создание объекта модели через билдер
    func build<ParametersType>() throws -> ParametersType where ParametersType: Parameters
}

/// Пустой объект модели
public struct Empty: UniversalModel {
    
    /// Инициализация
    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let response = try? container.decode([String: String].self), !response.isEmpty {
            throw NetworkError.parsing(Data())
        } else if let response = try? container.decode(String.self), !response.isEmpty || response != "{}" {
            if let data = response.data(using: .utf8) {
                throw NetworkError.parsing(data)
            } else {
                throw NetworkError.parsing(Data())
            }
        }
    }
}
