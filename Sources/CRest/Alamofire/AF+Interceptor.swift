//
//  AF+Interceptor.swift
//

import Alamofire
import Foundation

/// Обертка поверх `RequestInterceptor`
struct InterceptorWrapper: RequestInterceptor {
    
    private let interceptor: IOInterceptor
    
    init(_ interceptor: IOInterceptor) {
        self.interceptor = interceptor
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        interceptor.adapt(.init(request: urlRequest)) { result in
            switch result {
            case let .success(adapted):
                completion(.success(adapted.request))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func retry(_ request: Alamofire.Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let urlRequest = request.request {
            if is401Error(request) {
                interceptor.handleUnauthorized(request)
            }
            let result = interceptor.retry(urlRequest, request.response, request.retryCount, dueTo: error)
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
    
    private func is401Error(_ request: Alamofire.Request) -> Bool {
        request.response?.statusCode == 401
    }
}
