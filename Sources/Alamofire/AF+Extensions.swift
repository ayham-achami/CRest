//
//  AF+Extensions.swift
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

import Alamofire
import Foundation

// MARK: - DownloadRequest + ProgressController
extension Alamofire.DownloadRequest: ProgressController {

    public func pauseProgress() {
        suspend()
    }

    public func resumeProgress() {
        resume()
    }

    public func cancelProgress() {
        cancel(producingResumeData: true)
    }
}

// MARK: - UploadRequest + ProgressController
extension Alamofire.UploadRequest: ProgressController {

    public func pauseProgress() {
        suspend()
    }

    public func resumeProgress() {
        resume()
    }

    public func cancelProgress() {
        cancel()
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
