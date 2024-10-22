//
//  ProgressPublisher.swift
//

#if canImport(Combine)
import Combine
import Foundation

/// Publisher процесса выгрузки или загрузки
public final class ProgressPublisher<Response> where Response: CRest.Response {
    
    /// Ответ операции
    public let response: AnyPublisher<Response, Error>
    
    /// Процесс выгрузки или загрузки
    public let progress: AnyPublisher<Progress, Never>
    
    /// Инициализация
    /// - Parameters:
    ///   - response: Ответ операции
    ///   - progress: Процесс выгрузки или загрузки
    public init(response: AnyPublisher<Response, Error>, progress: AnyPublisher<Progress, Never>) {
        self.response = response
        self.progress = progress
    }
    
    /// Возвращает процесс
    /// - Parameters:
    ///   - subscription: Set подписок
    ///   - receive: Замыкание процесса
    /// - Returns: `ProgressPublisher`
    @discardableResult
    public func progress(for subscriptions: inout Set<AnyCancellable>, _ receive: @Sendable @escaping (Progress) -> Void) -> Self {
        progress.sink(receiveValue: receive).store(in: &subscriptions)
        return self
    }
    
    /// Возвращает процесс
    /// - Parameters:
    ///   - subscription: Set подписок
    ///   - receive: Замыкание получения ответа
    /// - Returns: `ProgressPublisher`
    @discardableResult
    public func response(for subscriptions: inout Set<AnyCancellable>, _ receive: @Sendable @escaping (Result<Response, Error>) -> Void) -> Self {
        response.sink { completion in
            guard case let .failure(error) = completion else { return }
            receive(.failure(error))
        } receiveValue: { response in
            receive(.success(response))
        }.store(in: &subscriptions)
        return self
    }
}
#endif
