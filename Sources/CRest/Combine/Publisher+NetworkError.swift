//
//  Publisher+NetworkError.swift
//

import Combine
import Foundation

extension Publisher where Failure: Error {
    
    func setFailureNetworkError() -> Publishers.MapError<Self, NetworkError> {
        mapError { $0 as! NetworkError } // swiftlint:disable:this force_cast
    }
}
