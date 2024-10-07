//
//  AF+DynamicRequest.swift
//

import Alamofire
import Foundation

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
             throw serializer.encountered(error, request, response, decoder, data)
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
            if let fileURL {
                try serializer.serialize(fileURL, request, response)
                return empty
            } else {
                return empty
            }
        } else if let fileURL {
            return try serializer.serialize(fileURL, decoder, request, response)
        } else {
            throw AFError.responseSerializationFailed(reason: .inputFileNil)
        }
    }
}
