//
//  AnyCodable.swift
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

@frozen public struct AnyCodable: Codable, AnyDecodable, AnyEncodable {
    
    public let base: Any
    
    public init<Base>(_ base: Base?) {
        self.base = base ?? ()
    }
}

extension AnyCodable: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self.base = nilLiteral
    }
}

extension AnyCodable: ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: Bool) {
        self.base = value
    }
}

extension AnyCodable: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.base = value
    }
}

extension AnyCodable: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: Double) {
        self.base = value
    }
}

extension AnyCodable: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.base = value
    }
}

extension AnyCodable: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Codable
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.base = elements
    }
}

extension AnyCodable: ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = Codable
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.base = elements
    }
}

extension AnyCodable: Equatable {
    
    // swiftlint:disable:next cyclomatic_complexity
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.base, rhs.base) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension AnyCodable: Hashable {
    
    // swiftlint:disable:next cyclomatic_complexity
    public func hash(into hasher: inout Hasher) {
        switch base {
        case let base as Bool:
            hasher.combine(base)
        case let base as Int:
            hasher.combine(base)
        case let base as Int8:
            hasher.combine(base)
        case let base as Int16:
            hasher.combine(base)
        case let base as Int32:
            hasher.combine(base)
        case let base as Int64:
            hasher.combine(base)
        case let base as UInt:
            hasher.combine(base)
        case let base as UInt8:
            hasher.combine(base)
        case let base as UInt16:
            hasher.combine(base)
        case let base as UInt32:
            hasher.combine(base)
        case let base as UInt64:
            hasher.combine(base)
        case let base as Float:
            hasher.combine(base)
        case let base as Double:
            hasher.combine(base)
        case let base as String:
            hasher.combine(base)
        case let base as [String: AnyCodable]:
            hasher.combine(base)
        case let base as [AnyCodable]:
            hasher.combine(base)
        default:
            break
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    
    public var description: String {
        guard
            let convertible = base as? CustomStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.description
    }
}

extension AnyCodable: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        guard
            let convertible = base as? CustomDebugStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.debugDescription
    }
}
