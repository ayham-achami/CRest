//
//  AF+Error.swift
//

import Alamofire
import Foundation

// MARK: - AFError + Reason
extension AFError {
 
    /// Конвертирует `AFError` в `NetworkError`
    /// - Parameter error: Alamofire error `AFError`
    func reason(with statusCode: Int?, responseData: Data? = nil) -> NetworkError {
        if isExplicitlyCancelledError {
            .explicitlyCancelled
        } else if case let .responseSerializationFailed(reason) = self {
            networkError(from: reason)
        } else if case let .responseValidationFailed(reason) = self {
            networkError(from: reason, responseData: responseData)
        } else if isServerTrustEvaluationError {
            .ssl(errorDescription ?? "\(String(describing: destinationURL))")
        } else if let statusCode = statusCode {
            .http(statusCode, data: responseData)
        } else if case let .sessionTaskFailed(error as NSError) = self {
            if error.code == NSURLErrorNotConnectedToInternet {
                .notConnected
            } else if error.code == NSURLErrorNetworkConnectionLost {
                .connectionLost
            } else {
                .io(error.message)
            }
        } else if let description = errorDescription {
            .io(description)
        } else {
            .io(localizedDescription)
        }
    }
}

// MARK: - AFError + NetworkError
private extension AFError {
    
    func networkError(from reason: ResponseSerializationFailureReason) -> NetworkError {
        switch reason {
        case .inputDataNilOrZeroLength:
            .io("Data is nil")
        case .inputFileNil:
            .io("File unreadable input is nil")
        case .inputFileReadFailed(let at):
            .io("File \(at.lastPathComponent) unreadable")
        case .stringSerializationFailed(let encoding):
            .io("Serialization failed \(encoding)")
        case .decodingFailed(let error),
             .jsonSerializationFailed(let error),
             .customSerializationFailed(let error):
            if let error = error as? ServerError {
                .server(error)
            } else {
                .io("Serialization failed \(error.message)")
            }
        case .invalidEmptyResponse(let type):
            .io("Invalid empty for \(type)")
        }
    }
    
    func networkError(from reason: ResponseValidationFailureReason, responseData: Data? = nil) -> NetworkError {
        switch reason {
        case .dataFileNil:
            .io("Data is nil")
        case .dataFileReadFailed(let at):
            .io("File \(at.lastPathComponent) unreadable")
        case .missingContentType:
            .io("Unacceptable content type")
        case .unacceptableContentType:
            .io("Unacceptable content type")
        case .unacceptableStatusCode(let code):
            .http(code, data: responseData)
        case .customValidationFailed(let error):
            .io("Validation failed \(error.message)")
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
    
    func networkError(default: NetworkError, transform: (AFError) -> NetworkError) -> NetworkError {
        (self as? AFError).map(transform) ?? `default`
    }
}

// MARK: - Error + LocalizedError
private extension Error {
    
    var localizedError: LocalizedError? {
        self as? LocalizedError
    }
    
    var message: String {
        asAFError?.errorDescription ?? localizedError?.errorDescription ?? localizedDescription
    }
}
