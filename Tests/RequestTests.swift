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

// MARK: - Request
extension Request {

    static var endPoint: EndPoint { EndPoint(rawValue: "https://myhost-on-dev.or.stage.com") }
    static var endPointAPI: EndPoint { EndPoint(rawValue: "\(endPoint.rawValue)/api") }
    
    /// Инициализация
    /// - Parameter path: Путь запроса
    init(pathAPI: String) {
        self.init(endPoint: Request.endPointAPI, path: pathAPI)
    }
    
    static var get: Request { .init(pathAPI: "/public/get") }
    static var query: Request { .init(pathAPI: "/public?pin=1234") }
    static var queryValue: Request { .init(pathAPI: "/public?pin=1234&somevalue=somestring") }
    static var queryValueArray: Request { .init(pathAPI: "/public?pin=1234&somevalue=somestring&array=[1,2,3]") }
    static var queryValueArrayBool: Request { .init(pathAPI: "/public?pin=1234&somevalue=somestring&array=[1,2,3]&bool=true") }
    static var queryValueArrayBoolSpace: Request {.init(pathAPI: "/public?pin=1234&somevalue=somestring&array=[1,2,3]&bool=true&stringWithSpace=string space string") }
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
