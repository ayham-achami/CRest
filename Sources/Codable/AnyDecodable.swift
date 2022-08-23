//
//  AnyDecodable.swift
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

@usableFromInline
protocol AnyDecodable: Baseable {}

extension AnyDecodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.init(Optional<Self>.none)
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
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

@frozen public struct AnyResponse: Response, AnyDecodable, JSONRepresentable {
    
    public let base: Any
    
    public init<Base>(_ base: Base?) {
        self.base = base ?? ()
    }
}

extension AnyResponse: CustomStringConvertible {
    
    public var description: String {
        guard
            let convertible = base as? CustomStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.description
    }
}

extension AnyResponse: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        guard
            let convertible = base as? CustomDebugStringConvertible
        else { return String(describing: "\(type(of: base)): \(base)") }
        return convertible.debugDescription
    }
}

extension AnyResponse: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self.base = nilLiteral
    }
}

extension AnyResponse: ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: Bool) {
        self.base = value
    }
}

extension AnyResponse: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.base = value
    }
}

extension AnyResponse: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: Double) {
        self.base = value
    }
}

extension AnyResponse: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.base = value
    }
}

extension AnyResponse: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = AnyResponse
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.base = elements
    }
}

extension AnyResponse: ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = AnyResponse
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.base = elements
    }
}
