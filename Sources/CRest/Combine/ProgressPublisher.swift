//
//  ProgressPublisher.swift
//

import Combine
import Foundation

/// <#Description#>
public final class ProgressPublisher<Response> where Response: CRest.Response {
    
    /// <#Description#>
    public let response: AnyPublisher<Response, Error>
    
    /// <#Description#>
    public let progress: AnyPublisher<Progress, Never>
    
    /// <#Description#>
    /// - Parameters:
    ///   - response: <#response description#>
    ///   - progress: <#progress description#>
    public init(response: AnyPublisher<Response, Error>, progress: AnyPublisher<Progress, Never>) {
        self.response = response
        self.progress = progress
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - subscription: <#subscription description#>
    ///   - receive: <#receive description#>
    /// - Returns: <#description#>
    @discardableResult
    public func progress(for subscription: inout Set<AnyCancellable>, _ receive: @escaping (Progress) -> Void) -> Self {
        progress.sink(receiveValue: receive).store(in: &subscription)
        return self
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - subscription: <#subscription description#>
    ///   - receive: <#receive description#>
    /// - Returns: <#description#>
    @discardableResult
    public func response(for subscription: inout Set<AnyCancellable>, _ receive: @escaping (Result<Response, Error>) -> Void) -> Self {
        response.sink { completion in
            guard case let .failure(error) = completion else { return }
            receive(.failure(error))
        } receiveValue: { response in
            receive(.success(response))
        }.store(in: &subscription)
        return self
    }
}
