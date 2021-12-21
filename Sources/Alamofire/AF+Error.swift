//
//  AF+Error.swift
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

/// Конвертирует `AFError` в `NetworkError`
/// - Parameter error: Alamofire error `AFError`
public func reason(from error: AFError, _ statusCode: Int?, responseData: Data? = nil) -> NetworkError {
    if error.isExplicitlyCancelledError {
        return .explicitlyCancelled
    } else if error.isServerTrustEvaluationError {
            return .ssl(error.errorDescription ?? "\(String(describing: error.destinationURL))")
    } else if let statusCode = statusCode, !(200..<300).contains(statusCode) {
        return .http(statusCode, data: responseData)
    } else if case let .sessionTaskFailed(error as NSError) = error {
        if error.code == NSURLErrorNotConnectedToInternet {
            return .notConnected
        } else if error.code == NSURLErrorNetworkConnectionLost {
            return .connectionLost
        } else {
            return .io(error.asAFError?.errorDescription ?? error.localizedDescription)
        }
    } else if let description = error.errorDescription {
        return .io(description)
    } else {
        return .io(error.localizedDescription)
    }
}
