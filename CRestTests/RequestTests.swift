//
//  RequestTests.swift
//

@testable import CRest
import XCTest

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
        self.init(endPoint: Request.endPointAPI, path: pathAPI)
    }
}

class RequestTests: XCTestCase {

    func testURLEncoding() {
        XCTAssertNotNil(URL(string: Request.get.rawValue))
        XCTAssertNotNil(URL(string: Request.query.rawValue))
        XCTAssertNotNil(URL(string: Request.queryValue.rawValue))
        XCTAssertNotNil(URL(string: Request.queryValueArray.rawValue))
        XCTAssertNotNil(URL(string: Request.queryValueArrayBool.rawValue))
        XCTAssertNotNil(URL(string: Request.queryValueArrayBoolSpace.rawValue))
    }
}
