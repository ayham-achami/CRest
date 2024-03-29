//
//  AF+Trust.swift
//

#if compiler(>=5.6.0) && canImport(_Concurrency)
import Foundation

/// Http клиент
public protocol AsyncRestIO: AnyObject {
    
    typealias Source = URL
    typealias Destination = URL
    typealias ProgressHandler = (Progress) -> Void
    
    /// Инициализация
    /// - Parameter configuration: Общие настройки REST клиента
    init(_ configuration: RestIOConfiguration)
    
    /// Выполняет REST http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: ответ на запрос
    func perform<Response>(_ request: DynamicRequest, response: Response.Type) async throws -> Response where Response: CRest.Response
    
    /// Выполняет REST http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    /// - Returns: `DynamicResponse` c ответом на запрос
    func dynamicPerform<Response>(_ request: DynamicRequest, response: Response.Type) async throws -> DynamicResponse<Response> where Response: CRest.Response
    
    /// Скачает данные и сохраняет их на диске
    /// - Parameters:
    ///   - destination: Куда сохранить
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    ///   - progress: Замыкание отражающийся прогресс загрузки, вызывает периодический во время выполнения запроса
    /// - Returns: ответ на запрос
    func download<Response>(into destination: Destination,
                            with request: DynamicRequest,
                            response: Response.Type,
                            progress: ProgressHandler?) async throws -> Response where Response: CRest.Response
    
    /// Выгружает данные на сервер из указанного источника
    /// - Parameters:
    ///   - source: Откуда брать данные
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    ///   - progress: Замыкание отражающийся прогресс загрузки, вызывает периодический во время выполнения запроса
    /// - Returns: ответ на запрос
    func upload<Response>(from source: Source,
                          with request: DynamicRequest,
                          response: Response.Type,
                          progress: ProgressHandler?) async throws -> Response where Response: CRest.Response
}

/// Протокол конфигурации общих запросов
public protocol AsyncRestIOSendable {
    
    /// Получает данные из сервера по логике `APIResponse`
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - method: метод запроса `Http.Method`
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func send<Response, Parameters>(for request: Request,
                                    parameters: Parameters?,
                                    response: Response.Type,
                                    method: Http.Method,
                                    encoding: Http.Encoding) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters
}

// MARK: - AsyncRestIO + AsyncRestIOSendable
public extension AsyncRestIO where Self: AsyncRestIOSendable {
    
    /// Отправить Get запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    @discardableResult
    func fetch<Response, Parameters>(for request: Request,
                                     parameters: Parameters = Empty.value,
                                     response: Response.Type = Empty.self,
                                     encoding: Http.Encoding = .URL(.default)) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .get, encoding: encoding)
    }
    
    /// Отправить Post запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    @discardableResult
    func submit<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .post, encoding: encoding)
    }
    
    /// Отправить Put запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    @discardableResult
    func update<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .put, encoding: encoding)
    }
    
    /// Отправить Patch запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    @discardableResult
    func change<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .patch, encoding: encoding)
    }
    
    /// Отправить Delete запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Тип ответа
    ///   - parameters: Параметры запроса
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    @discardableResult
    func delete<Response>(for request: Request,
                          parameters: Parameters = Empty.value,
                          response: Response.Type = Empty.self,
                          encoding: Http.Encoding = .URL(.default)) async throws -> Response where Response: CRest.Response {
        try await send(for: request, parameters: parameters, response: response, method: .delete, encoding: encoding)
    }
    
    /// Отправить head запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - encoding: Енкоденг запроса `Http.Method`
    func prepare(for request: Request, encoding: Http.Encoding = .URL(.default)) async throws {
        _ = try await send(for: request, parameters: Empty.value, response: Empty.self, method: .head, encoding: encoding)
    }
    
    /// Отправить Options запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    @discardableResult
    func setup<Response>(for request: Request,
                         response: Response.Type = Empty.self,
                         encoding: Http.Encoding = .URL(.default)) async throws -> Response where Response: CRest.Response {
        try await send(for: request, parameters: Empty.value, response: response, method: .options, encoding: encoding)
    }
}
#endif
