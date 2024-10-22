//
//  AnyEncodable.swift
//

import Foundation

/// Любой Encodable объект
@usableFromInline
protocol AnyEncodable: Baseable {}

// MARK: - AnyEncodable
extension AnyEncodable {
    
    // swiftlint:disable:next cyclomatic_complexity
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch base {
        case is NSNull:
            try container.encodeNil()
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        case let array as [AnyParameters]:
            try container.encode(array.map { AnyParameters($0) })
        case let dictionary as [String: AnyParameters]:
            try container.encode(dictionary.mapValues { AnyParameters($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(base, context)
        }
    }
}

/// Любые параметры запроса
@frozen public struct AnyParameters: Parameters, AnyEncodable, JSONRepresentable {
    
    public let base: Sendable
    
    public init<Base>(_ base: Base?) {
        self.base = base ?? ()
    }
}

// MARK: - AnyEncodable + CustomStringConvertible
extension AnyParameters: CustomStringConvertible {
    
    public var description: String {
        guard
            let convertible = base as? CustomStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.description
    }
}

// MARK: - AnyEncodable + CustomDebugStringConvertible
extension AnyParameters: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        guard
            let convertible = base as? CustomDebugStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.debugDescription
    }
}

// MARK: - AnyEncodable + ExpressibleByNilLiteral
extension AnyParameters: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self.base = nilLiteral
    }
}

// MARK: - AnyEncodable + ExpressibleByBooleanLiteral
extension AnyParameters: ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: Bool) {
        self.base = value
    }
}

// MARK: - AnyEncodable + ExpressibleByIntegerLiteral
extension AnyParameters: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.base = value
    }
}

// MARK: - AnyEncodable + ExpressibleByFloatLiteral
extension AnyParameters: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: Double) {
        self.base = value
    }
}

// MARK: - AnyEncodable + ExpressibleByStringLiteral
extension AnyParameters: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.base = value
    }
}

// MARK: - AnyEncodable + ExpressibleByArrayLiteral
extension AnyParameters: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = AnyParameters
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.base = elements
    }
}

// MARK: - AnyEncodable + ExpressibleByDictionaryLiteral
extension AnyParameters: ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = AnyParameters
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.base = elements
    }
}
