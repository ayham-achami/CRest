//
//  AF+Extensions.swift
//

import Alamofire
import Foundation

// MARK: - DataResponse + ResponseLog
extension Alamofire.DataResponse: ResponseLog {

    public var responseDescription: String {
        debugDescription
    }

    public var curl: String {
        request?.curl ?? "Undefined"
    }
}

// MARK: - Request + RequestLog
extension Alamofire.Request: RequestLog {

    public var requestDescription: String {
        description
    }

    public var curl: String {
        cURLDescription()
    }
}

// MARK: - DownloadResponse + ResponseLog
extension Alamofire.AFDownloadResponse: ResponseLog {

    public var responseDescription: String {
        debugDescription
    }

    public var curl: String {
        request?.curl ?? "Undefined"
    }
}

// MARK: - Request + validate
extension Alamofire.DataRequest {
    
    public func validate(_ validate: Bool) -> Self {
        validate ? self.validate() : self
    }
}

// MARK: - Request + validate
extension Alamofire.DownloadRequest {
    
    public func validate(_ validate: Bool) -> Self {
        validate ? self.validate() : self
    }
}

// MARK: - Request + validate
extension Alamofire.DataStreamRequest {
    
    public func validate(_ validate: Bool) -> Self {
        validate ? self.validate() : self
    }
}
