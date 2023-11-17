//
//  ProgressPublisher.swift
//

import Combine
import Foundation

public class ProgressPublisher<Response> where Response: CRest.Response {
    
    public var cancellable: Set<AnyCancellable>
    public let response: AnyPublisher<Response, Error>
    public let progress: AnyPublisher<Progress, Swift.Never>
    
    public init(response: AnyPublisher<Response, Error>,
                progress: AnyPublisher<Progress, Swift.Never>,
                cancellable: Set<AnyCancellable> = []) {
        self.response = response
        self.progress = progress
        self.cancellable = cancellable
    }
    
    public func progress(_ closure: @escaping (Progress) -> Void) -> Self {
        progress
            .sink(receiveValue: closure)
            .store(in: &cancellable)
        return self
    }
    
    public func response(_ receive: @escaping (Result<Response, Error>) -> Void) -> Self {
        response.sink(receiveCompletion: { completion in
            switch completion {
            case let .failure(error):
                receive(.failure(error))
            case .finished:
                break
            }
        }, receiveValue: { value in
            receive(.success(value))
        })
        .store(in: &cancellable)
        return self
    }
}
