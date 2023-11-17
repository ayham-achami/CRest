//
//  RestIOTestCase.swift
//

@testable import CRest
import Foundation
import XCTest

class RestIOTestCase: XCTestCase {
    
    let timeout: TimeInterval = 10
}

final class AsyncRestIOTestCase: RestIOTestCase {
    
    lazy var io: AsyncRestIO = AsyncAlamofireRestIO(RestConfiguration())
}

final class CombineRestIOTestCase: RestIOTestCase {
    
    lazy var io: CombineRestIO = CombineAlamofireRestIO(RestConfiguration())
}
