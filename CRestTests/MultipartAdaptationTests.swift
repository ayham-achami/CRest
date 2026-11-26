//
//  MultipartAdaptationTests.swift
//

@testable import CRest
import Foundation
import Testing

struct MultipartAdaptationTests {

    private final class ControlledAdapter: IOInterceptor, IORequestMultipartAdapter, @unchecked Sendable {

        private let lock = NSLock()
        private var completions: [Data: @Sendable (Result<Data, Error>) -> Void] = [:]
        let started: AsyncStream<Data>
        private let events: AsyncStream<Data>.Continuation

        init() {
            let stream = AsyncStream<Data>.makeStream()
            started = stream.stream
            events = stream.continuation
        }
        
        func adapt(_ data: Data, completion: @Sendable @escaping (Result<Data, Error>) -> Void) {
            lock.lock()
            completions[data] = completion
            lock.unlock()
            events.yield(data)
        }

        func complete(_ data: Data) {
            lock.lock()
            let completion = completions.removeValue(forKey: data)
            lock.unlock()
            completion?(.success(data))
        }
    }

    @Test("Адаптация сохраняет исходный порядок multipart-частей")
    func preservesMultipartOrder() async throws {
        let parameters: MultipartParameters = [
            DataMultipartParameter(Data([1]), "first"),
            DataMultipartParameter(Data([2]), "second")
        ]
        let adapter = ControlledAdapter()
        let request = try DynamicRequest.Builder()
            .with(url: "https://example.com/upload")
            .with(encoding: .multipart)
            .with(parameters: parameters)
            .with(interceptors: [adapter])
            .build()
        let multipart = try #require(ConcurrencyRestIO.MultipartRequest(request))
        let io = ConcurrencyRestIO(io: AsyncAlamofireRestIO(RestConfiguration()))

        let task = Task { try await io.adapt(multipart) }
        var started = adapter.started.makeAsyncIterator()
        let firstStarted = await started.next()
        let secondStarted = await started.next()
        #expect(Set([firstStarted, secondStarted].compactMap { $0 }) == Set([Data([1]), Data([2])]))

        adapter.complete(Data([2]))
        await Task.yield()
        adapter.complete(Data([1]))
        let adapted = try await task.value
        let result = try #require(adapted.parameters as? MultipartParameters)

        #expect(result.compactMap { ($0 as? DataMultipartParameter)?.name } == ["first", "second"])
    }
}
