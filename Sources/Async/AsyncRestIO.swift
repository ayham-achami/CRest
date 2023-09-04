//
//  AF+Trust.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Community Arch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    
    @discardableResult
    /// Отправить Get запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func fetch<Response, Parameters>(for request: Request,
                                     parameters: Parameters = Empty.value,
                                     response: Response.Type = Empty.self,
                                     encoding: Http.Encoding) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .get, encoding: encoding)
    }
    
    @discardableResult
    /// Отправить Post запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func submit<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .post, encoding: encoding)
    }
    
    @discardableResult
    /// Отправить Put запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func update<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .put, encoding: encoding)
    }
    
    @discardableResult
    /// Отправить Patch запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - parameters: Параметры запроса
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func change<Response, Parameters>(for request: Request,
                                      parameters: Parameters = Empty.value,
                                      response: Response.Type = Empty.self,
                                      encoding: Http.Encoding = .JSON) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        try await send(for: request, parameters: parameters, response: response, method: .patch, encoding: encoding)
    }
    
    @discardableResult
    /// Отправить Delete запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Тип ответа
    ///   - parameters: Параметры запроса
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
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
    
    @discardableResult
    /// Отправить Options запрос
    /// - Parameters:
    ///   - request: Запрос
    ///   - response: Тип ответа
    ///   - encoding: Енкоденг запроса `Http.Method`
    /// - Returns: Ответ сервера
    func setup<Response>(for request: Request,
                         response: Response.Type = Empty.self,
                         encoding: Http.Encoding = .URL(.default)) async throws -> Response where Response: CRest.Response {
        try await send(for: request, parameters: Empty.value, response: response, method: .options, encoding: encoding)
    }
}
#endif
