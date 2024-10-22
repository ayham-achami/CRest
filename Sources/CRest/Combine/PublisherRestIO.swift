//
//  PublisherRestIO.swift
//

#if canImport(Combine)
import Combine
import Foundation

/// Отправитель Http запросов с использованием Combine
open class PublisherRestIO: CombineRestIOSendable {
    
    /// Http клиент с использованием Combine
    public let io: CombineRestIO
    
    /// Инициализация
    /// - Parameter io: `CombineRestIO`
    public init(io: CombineRestIO) {
        self.io = io
    }
    
    /// Скачает данные и сохраняет их на диске
    /// - Parameters:
    ///   - destination: Куда сохранить
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: ответ на запрос
    open func download<Response>(into destination: CombineRestIO.Destination,
                                 with request: DynamicRequest,
                                 response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        io.download(into: destination, with: request, response: response)
    }
    
    /// Выгружает данные на сервер из указанного источника
    /// - Parameters:
    ///   - source: Откуда брать данные
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: ответ на запрос
    final public func upload<Response>(from source: CombineRestIO.Source,
                                       with request: DynamicRequest,
                                       response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response {
        io.upload(from: source, with: request, response: response)
    }
    
    open func send<Response, Parameters>(for request: Request,
                                         parameters: Parameters?,
                                         response: Response.Type,
                                         method: Http.Method, encoding: Http.Encoding) -> AnyPublisher<Response, any Error> where Response: CRest.Response, Parameters: CRest.Parameters {
        DynamicRequest
            .Builder()
            .with(method: method)
            .with(encoding: encoding)
            .with(url: request.rawValue)
            .with(parameters: parameters)
            .publishBuild()
            .flatMap { [weak self] request in
                self?.io.perform(request, response: response) ?? .empty
            }.eraseToAnyPublisher()
    }
}

// MARK: - DynamicRequest.Builder + Publisher
public extension DynamicRequest.Builder {
    
    /// Создает запрос
    /// - Returns: `AnyPublisher<DynamicRequest, Error>`
    func publishBuild() -> AnyPublisher<DynamicRequest, Error> {
        do {
            return Just(try build()).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

// MARK: - AnyPublisher + CRest.Response
public extension AnyPublisher {
    
    /// Возвращает пустой Publisher, у которого немедленно будет вызван блок завершения
    static var empty: Self {
        Combine.Empty<Output, Failure>(completeImmediately: true).eraseToAnyPublisher()
    }
}
#endif
