//
//  DynamicRequestTests.swift
//

@testable import CRest
import Testing

struct DynamicRequestTests {
    
    @Test("Создаёт запрос с заданными настройками")
    func testBuildEmpty() throws {
        let request = try DynamicRequest.Builder()
                .with(url: "http://path.to/resorce")
                .with(cacheBehavior: .default)
                .with(emptyRequestMethods: .init(Http.Method.allCases))
                .with(emptyResponseCodes: .init(200...204))
                .with(method: .get)
                .with(encoding: .JSON)
                .with(validate: false)
                .build()
            
        #expect(request.url == "http://path.to/resorce")
        guard case .default = request.cacheBehavior else {
            Issue.record("Request cacheBehavior not default")
            return
        }
        #expect(request.emptyRequestMethods == .init(Http.Method.allCases))
        #expect(request.emptyResponseCodes == .init(200...204))
        #expect(request.method == .get)
        guard case .JSON = request.encoding else {
            Issue.record("Request encoding not JSON")
            return
        }
        #expect(!request.validate)
    }
}
