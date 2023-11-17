//
//  AnyDecodable.swift
//

import Foundation

/// Любой Decodable объект
@usableFromInline
protocol AnyDecodable: Baseable {}

// MARK: - AnyDecodable + Default
extension AnyDecodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.init(Optional<Self>.none)
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyResponse].self) {
            self.init(array.map { $0.base })
        } else if let dictionary = try? container.decode([String: AnyResponse].self) {
            self.init(dictionary.mapValues { $0.base })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

/// Любой ответ
@frozen public struct AnyResponse: Response, AnyDecodable, JSONRepresentable {
    
    public let base: Any
    
    public init<Base>(_ base: Base?) {
        self.base = base ?? ()
    }
}

// MARK: - AnyResponse + CustomStringConvertible
extension AnyResponse: CustomStringConvertible {
    
    public var description: String {
        guard
            let convertible = base as? CustomStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.description
    }
}

// MARK: - AnyResponse + CustomDebugStringConvertible
extension AnyResponse: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        guard
            let convertible = base as? CustomDebugStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.debugDescription
    }
}

// MARK: - AnyResponse + ExpressibleByNilLiteral
extension AnyResponse: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self.base = nilLiteral
    }
}

// MARK: - AnyResponse + ExpressibleByBooleanLiteral
extension AnyResponse: ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: Bool) {
        self.base = value
    }
}

// MARK: - AnyResponse + ExpressibleByIntegerLiteral
extension AnyResponse: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.base = value
    }
}

// MARK: - AnyResponse + ExpressibleByFloatLiteral
extension AnyResponse: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: Double) {
        self.base = value
    }
}

// MARK: - AnyResponse + ExpressibleByStringLiteral
extension AnyResponse: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.base = value
    }
}

// MARK: - AnyResponse + ExpressibleByArrayLiteral
extension AnyResponse: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = AnyResponse
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.base = elements
    }
}

// MARK: - AnyResponse + ExpressibleByDictionaryLiteral
extension AnyResponse: ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = AnyResponse
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.base = elements
    }
}
