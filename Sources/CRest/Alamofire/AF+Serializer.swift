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
    let downloadsSerializationStrategy: DownloadsSerializationStrategy
    
    init(_ request: DynamicRequest) {
        self.decoder = request.decoder
        self.serializer = request.serializer
        self.emptyResponseCodes = request.emptyResponseCodes
        self.emptyRequestMethods = request.afEmptyRequestMethods
        self.downloadsSerializationStrategy = request.downloadsSerializationStrategy
    }
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Response {
        if let error {
            let networkError = error.networkError(default: .somethingWrong) { $0.reason(with: response?.statusCode, responseData: data) }
            throw serializer.encountered(networkError, request, response, decoder, data)
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
            let data = fileURL.map { try? Data(contentsOf: $0) }?.map { $0 } // swiftlint:disable:this array_init
            let networkError = error.networkError(default: .somethingWrong) { $0.reason(with: response?.statusCode, responseData: data) }
            throw serializer.encountered(networkError, request, response, decoder, data)
        } else if let empty = CRest.Empty() as? Response {
            guard
                emptyResponseAllowed(forRequest: request, response: response)
            else { throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength) }
            if let fileURL {
                switch downloadsSerializationStrategy {
                case .chunkedBody(let chunkSize, let expectedSize):
                    try serializer.serialize(fileURL,
                                             chunkSize,
                                             expectedSize,
                                             request,
                                             response)
                case .singleBody:
                    try serializer.serialize(fileURL, request, response)
                }
                return empty
            } else {
                return empty
            }
        } else if case .chunkedBody = downloadsSerializationStrategy {
            throw NetworkError.io("Chunked download serialization requires an Empty response")
        } else if let fileURL {
            return try serializer.serialize(fileURL, decoder, request, response)
        } else {
            throw AFError.responseSerializationFailed(reason: .inputFileNil)
        }
    }
}
