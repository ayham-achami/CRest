//
//  AF+Interceptor.swift
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

/// Обертка поверх `RequestInterceptor`
struct InterceptorWrapper: RequestInterceptor {
    
    private let interceptor: IOInterceptor
    
    init(_ interceptor: IOInterceptor) {
        self.interceptor = interceptor
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let result = interceptor.adapt(.init(request: urlRequest))
        switch result {
        case let .success(adapted):
            completion(.success(adapted.request))
        case let .failure(error):
            completion(.failure(error))
        }
    }
    
    func retry(_ request: Alamofire.Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let urlRequest = request.request, let httpResponse = request.response {
            let result = interceptor.retry(urlRequest, httpResponse, request.retryCount, dueTo: error)
            switch result {
            case .omit:
                completion(.doNotRetry)
            case .retry:
                completion(.retry)
            case .drop(let error):
                completion(.doNotRetryWithError(error))
            case .delay(let timeInterval):
                completion(.retryWithDelay(timeInterval))
            }
        } else {
            completion(.doNotRetry)
        }
    }
}
