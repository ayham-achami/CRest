//
//  ChunkedMultipartTests.swift
//

@testable import CRest
import Foundation
import Testing

struct ChunkedMultipartTests {

    private enum AdapterError: Error { case failed }

    private struct Adapter: IOInterceptor, IORequestMultipartAdapter {
        let shouldFail: Bool

        func adapt(_ url: URL, chunkSize: Int, completion: @Sendable @escaping (Result<BodyStream, Error>) -> Void) {
            #expect(url == URL(fileURLWithPath: "/fixture/photo.jpg"))
            #expect(chunkSize == 131_072)
            if shouldFail {
                completion(.failure(AdapterError.failed))
            } else {
                completion(.success(BodyStream(stream: InputStream(data: Data("encrypted".utf8)), length: 9)))
            }
        }
    }

    private func request(shouldFail: Bool = false) throws -> DynamicRequest {
        let parameter = ChunkedStreamMultipartParameter(URL(fileURLWithPath: "/fixture/photo.jpg"),
                                                        "file",
                                                        chunkSize: 131_072)
        return try DynamicRequest.Builder()
            .with(url: "https://example.com/upload")
            .with(encoding: .multipart)
            .with(parameters: MultipartParameters(arrayLiteral: parameter))
            .with(interceptors: [Adapter(shouldFail: shouldFail)])
            .build()
    }

    @Test("Неподготовленный поток отклоняется до отправки")
    func rejectsUnpreparedStream() throws {
        let request = try request()
        #expect(throws: ChunkedStreamMultipartParameter.StreamError.streamNotFound) {
            try request.multipartFormData()
        }
    }

    @Test("Адаптированный поток становится файловой multipart-частью")
    func encodesPreparedStream() async throws {
        let request = try request()
        let multipart = try #require(ConcurrencyRestIO.MultipartRequest(request))
        let io = ConcurrencyRestIO(io: AsyncAlamofireRestIO(RestConfiguration()))

        let adapted = try await io.adapt(multipart)
        let form = try adapted.multipartFormData()
        let body = try #require(String(data: form.encode(), encoding: .utf8))

        #expect(form.contentLength == 9)
        #expect(body.contains("name=\"file\""))
        #expect(body.contains("filename=\"photo.jpg\""))
        #expect(body.contains("Content-Type: image/jpeg"))
        #expect(body.contains("encrypted"))
    }

    @Test("Ошибка подготовки потока передаётся вызывающему коду")
    func propagatesAdapterError() async throws {
        let request = try request(shouldFail: true)
        let multipart = try #require(ConcurrencyRestIO.MultipartRequest(request))
        let io = ConcurrencyRestIO(io: AsyncAlamofireRestIO(RestConfiguration()))

        do {
            _ = try await io.adapt(multipart)
            Issue.record("Ожидалась ошибка адаптера")
        } catch {
            #expect(error as? AdapterError == .failed)
        }
    }
}
