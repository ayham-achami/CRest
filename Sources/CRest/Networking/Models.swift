//
//  Models.swift
//

import Foundation

/// Любой ответ любого запроса
public typealias Response = Decodable & Sendable

/// Любые параметры любого запроса
public typealias Parameters = Encodable & Sendable

/// Любые ответ и параметры любого запроса
public typealias Transferable = Codable & Sendable

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
public struct Empty: Codable {
    
    /// Инициализация
    public init() {}
}
