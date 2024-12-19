//
//  AF+Extensions.swift
//

import Alamofire
import Foundation

// MARK: - DataResponse + RestLog
extension Alamofire.DataResponse: RestLog {
    
    public var transactionMetrics: URLSessionTaskTransactionMetrics? {
        metrics?.transactionMetrics.first(where: { $0.request.url == request?.url })
    }
}

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

// MARK: - DownloadResponse + RestLog
extension Alamofire.AFDownloadResponse: RestLog {
    
    public var transactionMetrics: URLSessionTaskTransactionMetrics? {
        metrics?.transactionMetrics.first(where: { $0.request.url == request?.url })
    }
    
    public var data: Data? {
        nil
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
