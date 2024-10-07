//
//  AF+Error.swift
//

import Alamofire
import Foundation

extension AFError {
 
    /// Конвертирует `AFError` в `NetworkError`
    /// - Parameter error: Alamofire error `AFError`
    func reason(with statusCode: Int?, responseData: Data? = nil) -> NetworkError {
        if isExplicitlyCancelledError {
            return .explicitlyCancelled
        } else if case let .responseSerializationFailed(reason) = self,
                  case let .customSerializationFailed(error) = reason,
                  let serverError = error as? ServerError {
            return .server(serverError)
        } else if isServerTrustEvaluationError {
                return .ssl(errorDescription ?? "\(String(describing: destinationURL))")
        } else if let statusCode = statusCode {
            return .http(statusCode, data: responseData)
        } else if case let .sessionTaskFailed(error as NSError) = self {
            if error.code == NSURLErrorNotConnectedToInternet {
                return .notConnected
            } else if error.code == NSURLErrorNetworkConnectionLost {
                return .connectionLost
            } else {
                return .io(error.asAFError?.errorDescription ?? error.localizedDescription)
            }
        } else if let description = errorDescription {
            return .io(description)
        } else {
            return .io(localizedDescription)
        }
    }
}

// MARK: - Error + Session task failed
extension Error {
    
    var sessionFailed: NSError? {
        guard
            let afError = self as? AFError,
            case let AFError.sessionTaskFailed(error as NSError) = afError
        else { return nil }
        return error
    }
}
