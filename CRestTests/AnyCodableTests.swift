//
//  RequestTests.swift
//

@testable import CRest
import Foundation
import Testing

struct AnyCodableTests {
    
    @Test("Декодирует значения разных типов из JSON")
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

        #expect(response["boolean", Bool.self] == true)
        #expect(response["integer", Int.self] == 42)
        let double = try #require(response["double", Double.self])
        #expect(abs(double - 3.141592653589793) < 0.001)
        #expect(response["string", String.self] == "string")
        #expect(response["array", [Int].self] == [1, 2, 3])
        #expect(response["nested", [String: String].self] == ["a": "alpha", "b": "bravo", "c": "charlie"])
    }

    @Test("Кодирует вложенные параметры в JSON")
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
        #expect(response["intFocus", Int.self] == 0)
        #expect(response["boolFocus", Bool.self] == true)
        #expect(response["stringFocus", String.self] == "String")
        
        let anyFocus = AnyResponse(response["anyFocus", [String: any Sendable].self])
        #expect(anyFocus["intSome", Int.self] == 0)
        #expect(anyFocus["boolSome", Bool.self] == true)
        #expect(anyFocus["stringSome", String.self] == "String")
        
        let nested = AnyResponse(anyFocus["nestedSome", [String: any Sendable].self])
        #expect(nested["intNested", Int.self] == 0)
        #expect(nested["boolNested", Bool.self] == false)
        #expect(nested["stringNested", String.self] == "Nested String")
    }
}
