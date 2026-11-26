//
//  RequestTests.swift
//

@testable import CRest
import Foundation
import Testing

// MARK: - Request
extension Request {

    static var endPoint: EndPoint { EndPoint(rawValue: "https://myhost-on-dev.or.stage.com") }
    static var endPointAPI: EndPoint { EndPoint(rawValue: "\(endPoint.rawValue)/api") }
    
    static var get: Request { .init(pathAPI: "/public/get") }
    static var query: Request { .init(pathAPI: "/public?pin=1234") }
    static var queryValue: Request { .init(pathAPI: "/public?pin=1234&somevalue=somestring") }
    static var queryValueArray: Request { .init(pathAPI: "/public?pin=1234&somevalue=somestring&array=[1,2,3]") }
    static var queryValueArrayBool: Request { .init(pathAPI: "/public?pin=1234&somevalue=somestring&array=[1,2,3]&bool=true") }
    static var queryValueArrayBoolSpace: Request {.init(pathAPI: "/public?pin=1234&somevalue=somestring&array=[1,2,3]&bool=true&stringWithSpace=string space string") }
    
    /// Инициализация
    /// - Parameter path: Путь запроса
    init(pathAPI: String) {
        enum Keys: String, URLQueryKeys {
            case none
        }
        self.init(DynamicURL.Builder(keyedBy: Keys.self)
            .with(base: Request.endPoint.rawValue)
            .with(pathComponent: pathAPI).build())
    }
}

struct RequestTests {

    @Test("Создаёт корректные URL запросов")
    func testURLEncoding() {
        #expect(URL(string: Request.get.rawValue) != nil)
        #expect(URL(string: Request.query.rawValue) != nil)
        #expect(URL(string: Request.queryValue.rawValue) != nil)
        #expect(URL(string: Request.queryValueArray.rawValue) != nil)
        #expect(URL(string: Request.queryValueArrayBool.rawValue) != nil)
        #expect(URL(string: Request.queryValueArrayBoolSpace.rawValue) != nil)
    }
}
