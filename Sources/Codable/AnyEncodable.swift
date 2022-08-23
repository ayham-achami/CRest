//
//  AnyEncodable.swift
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
protocol AnyEncodable {
    
    var base: Any { get }
    
    init<Base>(_ base: Base?)
}

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
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let number as NSNumber:
            try encode(number: number, into: &container)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        case let array as [Any?]:
            try container.encode(array.map { AnyParameters($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyParameters($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(base, context)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func encode(number: NSNumber, into container: inout SingleValueEncodingContainer) throws {
        switch Character(Unicode.Scalar(UInt8(number.objCType.pointee))) {
        case "B":
            try container.encode(number.boolValue)
        case "c":
            try container.encode(number.int8Value)
        case "s":
            try container.encode(number.int16Value)
        case "i", "l":
            try container.encode(number.int32Value)
        case "q":
            try container.encode(number.int64Value)
        case "C":
            try container.encode(number.uint8Value)
        case "S":
            try container.encode(number.uint16Value)
        case "I", "L":
            try container.encode(number.uint32Value)
        case "Q":
            try container.encode(number.uint64Value)
        case "f":
            try container.encode(number.floatValue)
        case "d":
            try container.encode(number.doubleValue)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "number cannot be encoded because its type is not handled")
            throw EncodingError.invalidValue(number, context)
        }
    }
}

@frozen public struct AnyParameters: AnyEncodable, Encodable {
    
    public let base: Any
    
    public init<Base>(_ base: Base?) {
        self.base = base ?? ()
    }
}
