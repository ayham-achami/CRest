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

import Alamofire
import Foundation

// MARK: - DynamicRequest + Alamofire
extension DynamicRequest {
    
    public struct Wrapper: Encodable {
        
        let parameters: Parameters
        
        init?(_ parameters: Parameters?) {
            guard let parameters = parameters else { return nil }
            self.parameters = parameters
        }
        
        public func encode(to encoder: Encoder) throws {
            try parameters.encode(to: encoder)
        }
    }

    public var afHeders: Alamofire.HTTPHeaders {
        HTTPHeaders(headers)
    }

    public var afMethod: Alamofire.HTTPMethod {
        HTTPMethod(rawValue: method.rawValue)
    }

    public var afParameters: Wrapper? {
        switch encoding {
        case .URL, .JSON:
            return Wrapper(parameters)
        case .multipart:
            return nil
        }
    }

    public var afJSONEncoder: Alamofire.JSONParameterEncoder {
        JSONParameterEncoder(encoder: encoder)
    }
    
    public func encode(into data: MultipartFormData) {
        guard let parameters = parameters as? MultipartParameters  else { return }
        parameters.forEach {
            switch $0 {
            case let parameter as DataMultipartParameter:
                data.append(parameter.data, withName: parameter.name)
            #if canImport(UIKit)
            case let parameter as ImageMultipartParameter:
                data.append(parameter.data,
                            withName: parameter.name,
                            fileName: parameter.fileName,
                            mimeType: parameter.mime)
            #endif
            case let parameter as StreamMultipartParameter:
                data.append(parameter.url, withName: parameter.name)
            default:
                preconditionFailure("Not supported MultipartParameters type")
            }
        }
    }
}

// MARK: - EncodingConfiguration + URLEncodedFormParameterEncoder
extension Http.EncodingConfiguration {
    
    /// `URLEncodedFormParameterEncoder`
    public var URLEncoded: URLEncodedFormParameterEncoder {

        let arrayEncoding: URLEncodedFormEncoder.ArrayEncoding
        switch array {
        case .brackets:
            arrayEncoding = .brackets
        case .noBrackets:
            arrayEncoding = .noBrackets
        }
        
        let boolEncoding: URLEncodedFormEncoder.BoolEncoding
        switch bool {
        case .literal:
            boolEncoding = .literal
        case .numeric:
            boolEncoding = .numeric
        }
        
        let dataEncoding: URLEncodedFormEncoder.DataEncoding
        switch data {
        case .base64:
            dataEncoding = .base64
        case .deferredToData:
            dataEncoding = .deferredToData
        case let .custom(action):
            dataEncoding = .custom(action)
        }
        
        let dateEncoding: URLEncodedFormEncoder.DateEncoding
        switch date {
        case .iso8601:
            dateEncoding = .iso8601
        case .deferredToDate:
            dateEncoding = .deferredToDate
        case .secondsSince1970:
            dateEncoding = .secondsSince1970
        case .millisecondsSince1970:
            dateEncoding = .millisecondsSince1970
        case let .formatted(formatter):
            dateEncoding = .formatted(formatter)
        case let .custom(action):
            dateEncoding = .custom(action)
        }
        
        return .init(encoder: .init(arrayEncoding: arrayEncoding,
                                    boolEncoding: boolEncoding,
                                    dataEncoding: dataEncoding,
                                    dateEncoding: dateEncoding))
    }
}
