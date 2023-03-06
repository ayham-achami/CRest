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

#if compiler(>=5.5.2) && canImport(_Concurrency)
import Foundation

/// Http клиент
@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
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
#endif
