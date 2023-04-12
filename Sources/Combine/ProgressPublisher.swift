//
//  ProgressPublisher.swift
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

#if canImport(Combine)
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
#endif
