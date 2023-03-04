//
//  RequestTests.swift
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


