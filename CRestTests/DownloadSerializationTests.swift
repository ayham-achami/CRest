//
//  DownloadSerializationTests.swift
//

@testable import CRest
import Foundation
import Testing

struct DownloadSerializationTests {

    private struct NonEmptyResponse: Decodable {
        let value: String
    }

    private struct ChunkedCall: Equatable {
        let file: URL
        let expectedSize: UInt64
        let chunkSize: Int
    }

    private enum SerializationError: Error, Equatable {
        case single
        case chunked(ChunkedCall)
    }

    private struct Serializer: IOSerializer {
        func serialize(_ fileURL: URL, _ request: URLRequest?, _ response: HTTPURLResponse?) throws {
            throw SerializationError.single
        }

        func serialize(_ fileURL: URL, _ chunkSize: Int, _ expectedSize: UInt64,
                       _ request: URLRequest?, _ response: HTTPURLResponse?) throws {
            throw SerializationError.chunked(.init(file: fileURL, expectedSize: expectedSize, chunkSize: chunkSize))
        }
    }

    private func wrapper(strategy: DownloadsSerializationStrategy) throws -> ResponseSerializerWrapper<CRest.Empty> {
        let request = try DynamicRequest.Builder()
            .with(url: "https://example.com/download")
            .with(serializer: Serializer())
            .with(downloadsSerializationStrategy: strategy)
            .build()
        return ResponseSerializerWrapper(request)
    }

    @Test("Single body выбирает обычный файловый сериализатор")
    func selectsSingleBody() throws {
        let serializer = try wrapper(strategy: .singleBody)
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 204,
                                       httpVersion: nil, headerFields: nil)

        #expect(throws: SerializationError.single) {
            try serializer.serializeDownload(request: nil, response: response,
                                             fileURL: URL(fileURLWithPath: "/fixture/download"), error: nil)
        }
    }

    @Test("Chunked body передаёт размеры файловому сериализатору")
    func selectsChunkedBody() throws {
        let serializer = try wrapper(strategy: .chunkedBody(chunkSize: 65_536, expectedSize: 1_234_567))
        let file = URL(fileURLWithPath: "/fixture/download")
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 204,
                                       httpVersion: nil, headerFields: nil)

        #expect(throws: SerializationError.chunked(.init(file: file, expectedSize: 1_234_567, chunkSize: 65_536))) {
            try serializer.serializeDownload(request: nil, response: response, fileURL: file, error: nil)
        }
    }

    @Test("Chunked body отклоняет ответ, отличный от Empty")
    func rejectsChunkedBodyForNonEmptyResponse() throws {
        let request = try DynamicRequest.Builder()
            .with(url: "https://example.com/download")
            .with(downloadsSerializationStrategy: .chunkedBody(chunkSize: 65_536, expectedSize: 10))
            .build()
        let serializer = ResponseSerializerWrapper<NonEmptyResponse>(request)

        #expect(throws: NetworkError.io("Chunked download serialization requires an Empty response")) {
            try serializer.serializeDownload(request: nil, response: nil,
                                             fileURL: URL(fileURLWithPath: "/fixture/download"), error: nil)
        }
    }
}
