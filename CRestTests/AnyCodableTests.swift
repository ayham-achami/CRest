//
//  AnyCodableTests.swift
//  CRestTests
//
//  Created by Ayham Hylam on 08.08.2022.
//

import XCTest
@testable import CRest

class AnyCodableTests: XCTestCase {
    
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
        let response = try decoder.decode(AnyResponse.self, from: json)

        XCTAssertEqual(response["boolean", Bool.self]!, true)
        XCTAssertEqual(response["integer", Int.self]!, 42)
        XCTAssertEqual(response["double", Double.self]!, 3.141592653589793, accuracy: 0.001)
        XCTAssertEqual(response["string", String.self]!, "string")
        XCTAssertEqual(response["array", [Int].self]!, [1, 2, 3])
        XCTAssertEqual(response["nested", [String: String].self]!, ["a": "alpha", "b": "bravo", "c": "charlie"])
    }

    func testJSONEncoding() throws {
        
        struct Some: Parameters {

            struct Nested: Parameters {

                let intNested: Int = 0
                let boolNested: Bool = false
                let stringNested: String = "Nested String"
            }
            
            let intSome: Int = 0
            let boolSome: Bool = true
            let stringSome: String = "String"
            var nestedSome: Nested = .init()
        }
        
        struct Focus: Parameters {
            
            let intFocus: Int = 0
            let boolFocus: Bool = true
            let stringFocus: String = "String"
            
            let anyFocus: AnyParameters
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(Focus(anyFocus: .init(Some())))
        let string = String(data: data, encoding: .utf8)!
        XCTAssertEqual(string, "{\"stringFocus\":\"String\",\"boolFocus\":true,\"anyFocus\":{\"boolSome\":true,\"stringSome\":\"String\",\"intSome\":0,\"nestedSome\":{\"boolNested\":false,\"stringNested\":\"Nested String\",\"intNested\":0}},\"intFocus\":0}")
    }
}


