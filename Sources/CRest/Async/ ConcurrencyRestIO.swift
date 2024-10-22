//
//   ConcurrencyRestIO.swift
//

#if compiler(>=5.6.0) && canImport(_Concurrency)
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
    public func upload<Response>(from source: AsyncRestIO.Source,
                                 with request: DynamicRequest,
                                 response: Response.Type,
                                 progress: AsyncRestIO.ProgressHandler?) async throws -> Response where Response: CRest.Response {
        if let request = MultipartRequest(request) {
            try await io.upload(from: source, with: try await adapt(request), response: response, progress: progress)
        } else {
            try await io.upload(from: source, with: request, response: response, progress: progress)
        }
    }
    
    open func send<Response, Parameters>(for request: Request,
                                         parameters: Parameters?,
                                         response: Response.Type,
                                         method: Http.Method, encoding: Http.Encoding) async throws -> Response where Parameters: CRest.Parameters, Response: CRest.Response {
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

// MARK: - AsyncRestIO + MultipartRequest
private extension ConcurrencyRestIO {
    
    /// Multipart запрос
    struct MultipartRequest {
        
        /// Параметры Multipart
        let parameters: MultipartParameters
        /// адаптер запроса MultiPart
        let adapter: IORequestMultipartAdapter
        /// Динамический http запрос с `MultipartParameters`
        let builder: DynamicRequest.Builder
        
        init?(_ request: DynamicRequest) {
            guard
                let parameters = request.parameters as? MultipartParameters,
                let adapter = request.multipartAdapter
            else { return nil }
            self.adapter = adapter
            self.parameters = parameters
            self.builder = .init(request)
        }
    }
    
    func adapt(_ request: MultipartRequest) async throws -> DynamicRequest {
        try await withThrowingTaskGroup(of: MultipartParameter.self) { taskGroup in
            try await request.parameters
                .reduce(into: taskGroup) { group, parameter in
                    group.addTask { try await request.adapter.adapt(parameter) }
                }.reduce(into: MultipartParameters()) { result, parameter in
                    result.append(parameter)
                }.touch { parameters in
                    try request.builder.with(parameters: parameters).build()
                }
        }
    }
}
#endif
