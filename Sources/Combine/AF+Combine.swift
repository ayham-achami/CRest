//
//  AF+Combine.swift
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
import Alamofire
import Foundation

// MARK: - DownloadRequest
@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
extension Alamofire.DownloadRequest {
    
    /// Возвращать DownloadPublisher
    func response<Response>(of type: Response.Type,
                            queue: DispatchQueue,
                            decoder: DataDecoder = JSONDecoder(),
                            interceptor: RestInterceptor,
                            informant: NetworkInformant) -> AnyPublisher<Response, Error> where Response: CRest.Response {
        publishData(queue: queue).tryMap { response in
            informant.log(response: response)
            switch response.result {
            case .success:
                if let data = response.resumeData {
                    do {
                        return try decoder.decode(Response.self, from: data)
                    } catch {
                        throw NetworkError.parsing(data)
                    }
                } else if Response.self == Never.self {
                    // swiftlint:disable:next force_cast
                    return Empty.empty as! Response
                } else {
                    throw NetworkError.somethingWrong
                }
            case .failure(let error):
                throw reason(from: error, response.response?.statusCode, responseData: response.resumeData)
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - DataRequest
@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
extension Alamofire.DataRequest {

    func response<Response>(of type: Response.Type,
                            queue: DispatchQueue,
                            decoder: DataDecoder,
                            interceptor: RestInterceptor,
                            informant: NetworkInformant) -> AnyPublisher<Response, Error> where Response: CRest.Response {
        publishDecodable(type: type, queue: queue, decoder: decoder).tryMap { response in
            informant.log(response: response)
            switch response.result {
            case let .success(model):
                return model
            case let .failure(error):
                throw reason(from: error, response.response?.statusCode, responseData: response.data)
            }
        }.eraseToAnyPublisher()
    }
    
    func response<Response>(of type: Response.Type,
                            queue: DispatchQueue,
                            decoder: DataDecoder,
                            interceptor: RestInterceptor,
                            informant: NetworkInformant) -> AnyPublisher<DynamicResponse<Response>, Error> where Response: CRest.Response {
        publishDecodable(type: type, queue: queue, decoder: decoder).tryMap { response in
            informant.log(response: response)
            switch response.result {
            case let .success(model):
                return .init(model, response.response)
            case let .failure(error):
                throw reason(from: error, response.response?.statusCode, responseData: response.data)
            }
        }.eraseToAnyPublisher()
    }
}
#endif
