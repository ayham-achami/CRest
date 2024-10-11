//
//   ConcurrencyRestIO.swift
//

import Foundation

/// Отправитель Http запросов с использованием SwiftConcurrency
open class ConcurrencyRestIO: AsyncRestIOSendable {
    
    /// Http клиент с использованием SwiftConcurrency
    public let io: AsyncRestIO
    
    /// Инициализация
    /// - Parameter io: `AsyncRestIO`
    public init(io: AsyncRestIO) {
        self.io = io
    }
    
    /// Скачает данные и сохраняет их на диске
    /// - Parameters:
    ///   - destination: Куда сохранить
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    ///   - progress: Замыкание отражающийся прогресс загрузки, вызывает периодический во время выполнения запроса
    /// - Returns: ответ на запрос
    open func download<Response>(into destination: AsyncRestIO.Destination,
                                 with request: DynamicRequest,
                                 response: Response.Type,
                                 progress: AsyncRestIO.ProgressHandler?) async throws -> Response where Response: CRest.Response {
        try await io.download(into: destination, with: request, response: response, progress: progress)
    }
    
    /// Выгружает данные на сервер из указанного источника
    /// - Parameters:
    ///   - source: Откуда брать данные
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    ///   - progress: Замыкание отражающийся прогресс загрузки, вызывает периодический во время выполнения запроса
    /// - Returns: ответ на запрос
    open func upload<Response>(from source: AsyncRestIO.Source,
                               with request: DynamicRequest,
                               response: Response.Type,
                               progress: AsyncRestIO.ProgressHandler?) async throws -> Response where Response: CRest.Response {
        try await io.upload(from: source, with: request, response: response, progress: progress)
    }
    
    open func send<Response, Parameters>(for request: Request,
                                         parameters: Parameters?,
                                         response: Response.Type,
                                         method: Http.Method, encoding: Http.Encoding) async throws -> Response where Response: Decodable, Parameters: Encodable {
        let request = try DynamicRequest
            .Builder()
            .with(method: method)
            .with(encoding: encoding)
            .with(url: request.rawValue)
            .with(parameters: parameters)
            .build()
        return try await io.perform(request, response: Response.self)
    }
}
