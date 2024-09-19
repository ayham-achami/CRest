//
//  RequestTests.swift
//

@testable import CRest
import XCTest

class AnyCodableTests: XCTestCase {
    
    func testJSONDecoding() throws {
        let json = Data("""
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
        """.utf8)
        
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
        
        let data = try JSONEncoder().encode(Focus(anyFocus: .init(Some())))
        
        let response = try JSONDecoder().decode(AnyResponse.self, from: data)
        XCTAssertEqual(response["intFocus", Int.self], 0)
        XCTAssertEqual(response["boolFocus", Bool.self], true)
        XCTAssertEqual(response["stringFocus", String.self], "String")
        
        let anyFocus = AnyResponse(response["anyFocus", [String: Any].self])
        XCTAssertEqual(anyFocus["intSome", Int.self], 0)
        XCTAssertEqual(anyFocus["boolSome", Bool.self], true)
        XCTAssertEqual(anyFocus["stringSome", String.self], "String")
        
        let nested = AnyResponse(anyFocus["nestedSome", [String: Any].self])
        XCTAssertEqual(nested["intNested", Int.self], 0)
        XCTAssertEqual(nested["boolNested", Bool.self], false)
        XCTAssertEqual(nested["stringNested", String.self], "Nested String")
    }
}
