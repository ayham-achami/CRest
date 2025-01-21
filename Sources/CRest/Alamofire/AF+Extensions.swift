//
//  AF+Extensions.swift
//

import Alamofire
import Foundation

// MARK: - DataResponse + RestLog
extension Alamofire.DataResponse: RestLog {
    
    public var responseDescription: String {
        debugDescription
    }
    
    public var curl: String {
        request?.curl ?? "Undefined"
    }
    
    public var transactionMetrics: URLSessionTaskTransactionMetrics? {
        metrics?.transactionMetrics.first(where: { $0.request.url == request?.url })
    }
}

// MARK: - DownloadResponse + RestLog
extension Alamofire.AFDownloadResponse: RestLog {
    
    public var responseDescription: String {
        debugDescription
    }
    
    public var curl: String {
        request?.curl ?? "Undefined"
    }
    
    public var transactionMetrics: URLSessionTaskTransactionMetrics? {
        metrics?.transactionMetrics.first(where: { $0.request.url == request?.url })
    }
    
    public var data: Data? {
        nil
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
