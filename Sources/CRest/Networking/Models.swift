//
//  Models.swift
//

import Foundation

/// Любой ответ любого запроса
public typealias Response = Decodable

/// Любые параметры любого запроса
public typealias Parameters = Encodable

/// Любые параметры/ответ любого запроса
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public typealias UniversalModel = Codable

/// Любой ответ любого запроса в виде массива
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public typealias CollectionResponse = Response & CollectionRepresented

/// Любые параметры любого запроса в виде массива
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public typealias CollectionParameters = Parameters & CollectionRepresented

/// Протокол представления объекта модели в виде массива
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public protocol CollectionRepresented: Collection {

    /// Тип элемента массива
    associatedtype Item: Any

    /// Массив объектов модели
    var list: [Item] { get }
}

// MARK: - CollectionRepresented + Model
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
extension CollectionRepresented where Index == Int {

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
public protocol RawResponse: Response, RawRepresentable where RawValue: Response {

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
@frozen public struct Empty: Response, Parameters {
    
    /// Инициализация
    public init() {}
}
