//
//  Models.swift
//

import CFoundation
import Foundation

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

    public subscript(_ index: Index) -> Item {
        list[index]
    }
    
    public func index(after i: Int) -> Int {
        list.index(after: i)
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
@frozen public struct Empty: UniversalModel {
    
    /// Инициализация
    public init() {}

    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else { return }
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
