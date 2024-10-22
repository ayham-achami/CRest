//
//  DynamicRequestTests.swift
//

@testable import CRest
import XCTest

final class DynamicRequestTests: XCTestCase {
    
    func testBuildEmpty() {
        do {
            let request = try DynamicRequest.Builder()
                .with(url: "http://path.to/resorce")
                .with(cacheBehavior: .default)
                .with(emptyRequestMethods: .init(Http.Method.allCases))
                .with(emptyResponseCodes: .init(200...204))
                .with(method: .get)
                .with(encoding: .JSON)
                .with(validate: false)
                .build()
            
            XCTAssertEqual(request.url, "http://path.to/resorce")
            guard
                case .default = request.cacheBehavior
            else {
                XCTFail("Request cacheBehavior not default")
                return
            }
            XCTAssertEqual(request.emptyRequestMethods, .init(Http.Method.allCases))
            XCTAssertEqual(request.emptyResponseCodes, .init(200...204))
            XCTAssertEqual(request.method, .get)
            guard
                case .JSON = request.encoding
            else {
                XCTFail("Request encoding not JSON")
                return
            }
            XCTAssertFalse(request.validate)
        } catch {
            XCTFail("Request build error: \(error)")
        }
    }
}
