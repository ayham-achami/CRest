//
//  AF+DynamicRequest.swift
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

import Foundation
import Alamofire

/// Обертка поверх `ResponseSerializer`
struct ResponseSerializerWrapper<Response>: ResponseSerializer where Response: CRest.Response {
        
    private let decoder: JSONDecoder
    private let serializer: IOSerializer
    
    let emptyResponseCodes: Set<Int>
    let emptyRequestMethods: Set<HTTPMethod>
    
    init(_ request: DynamicRequest) {
        self.decoder = request.decoder
        self.serializer = request.serializer
        self.emptyResponseCodes = request.emptyResponseCodes
        self.emptyRequestMethods = request.afEmptyRequestMethods
    }
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Response {
        if let error {
            let error = serializer.encountered(error, for: request, and: response, data: data)
            throw error
        } else if let empty = CRest.Empty() as? Response {
            guard
                emptyResponseAllowed(forRequest: request, response: response)
            else { throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength) }
            return empty
        } else if let data, !data.isEmpty {
            return try serializer.serialize(data, decoder, request, response)
        } else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
    }
    
    func serializeDownload(request: URLRequest?, response: HTTPURLResponse?, fileURL: URL?, error: Error?) throws -> Response {
        if let error {
            throw error
        } else if let empty = CRest.Empty() as? Response {
            guard
                emptyResponseAllowed(forRequest: request, response: response)
            else { throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength) }
            return empty
        } else if let fileURL {
            return try serializer.serialize(fileURL, decoder, request, response)
        } else {
            throw AFError.responseSerializationFailed(reason: .inputFileNil)
        }
    }
}
