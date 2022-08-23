//
//  AnyCodableTests.swift
//  CRestTests
//
//  Created by Ayham Hylam on 08.08.2022.
//

import XCTest
@testable import CRest

class AnyCodableTests: XCTestCase {

    struct SomeCodable: Codable {
        
        enum CodingKeys: String, CodingKey {
            
            case string
            case int
            case bool
            case hasUnderscore = "has_underscore"
        }
        
        var string: String
        var int: Int
        var bool: Bool
        var hasUnderscore: String
    }
    
    func testJSONDecoding() throws {
        let json = """
        {
            "boolean": true,
            "integer": 42,
            "double": 3.141592653589793,
            "string": "string",
            "array": [1, 2, 3],
            "nested": {
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            },
            "null": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let dictionary = try decoder.decode([String: AnyCodable].self, from: json)

        XCTAssertEqual(dictionary["boolean", Bool.self], true)
        XCTAssertEqual(dictionary["integer", Int.self], 42)
        XCTAssertEqual(dictionary["double", Double.self], 3.141592653589793, accuracy: 0.001)
        XCTAssertEqual(dictionary["string", String.self], "string")
        XCTAssertEqual(dictionary["array", [Int].self], [1, 2, 3])
        XCTAssertEqual(dictionary["nested", [String: String].self], ["a": "alpha", "b": "bravo", "c": "charlie"])
        XCTAssertEqual(dictionary["null", NSNull.self], NSNull())
    }

    func testJSONEncoding() throws {
        
        let someCodable = AnyCodable(SomeCodable(string: "String", int: 100, bool: true, hasUnderscore: "another string"))
        
        let dictionary: [String: AnyCodable] = [
            "boolean": true,
            "integer": 42,
            "double": 3.141592653589793,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
            ],
            "someCodable": someCodable,
            "null": nil
        ]

        let encoder = JSONEncoder()
        let json = try encoder.encode(dictionary)
        let encodedJSONObject = try JSONSerialization.jsonObject(with: json, options: []) as? NSDictionary
        
        let expected = """
        {
            "boolean": true,
            "integer": 42,
            "double": 3.141592653589793,
            "string": "string",
            "array": [1, 2, 3],
            "nested": {
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            },
            "someCodable": {
                "string":"String",
                "int":100,
                "bool": true,
                "has_underscore":"another string"
            },
            "null": null
        }
        """.data(using: .utf8)!
        let expectedJSONObject = try JSONSerialization.jsonObject(with: expected, options: []) as? NSDictionary
        XCTAssertEqual(encodedJSONObject, expectedJSONObject)
    }
}

private extension Dictionary where Value == AnyCodable {
    
    subscript<Base>(key: Key, type: Base.Type) -> Base {
        guard
            let value = self[key] as? Base
        else {
            preconditionFailure("Value \(String(describing: self[key])) not an instance of \(String(describing: Base.self))")
        }
        return value
    }
}
