//
//  CombineRestIO.swift
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

#if canImport(Combine)
import Combine
import Foundation

/// Http клиент с использованием Combine
public protocol CombineRestIO: AnyObject {
    
    typealias Source = URL
    typealias Destination = URL
    
    /// Инициализация
    /// - Parameter configuration: Общие настройки REST клиента
    init(_ configuration: RestIOConfiguration)
    
    /// Выполняет REST http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func perform<Response>(_ request: DynamicRequest,
                           response: Response.Type) -> AnyPublisher<Response, Error> where Response: CRest.Response
    
    /// Выполняет REST http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func perform<Response>(_ request: DynamicRequest,
                           response: Response.Type) -> AnyPublisher<DynamicResponse<Response>, Error> where Response: CRest.Response
    
    /// Скачает данные и сохраняет их на диске
    /// - Parameters:
    ///   - destination: Куда сохранить
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func download<Response>(into destination: Destination,
                            with request: DynamicRequest,
                            response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response
    
    /// Выгружает данные на сервер из указанного источника
    /// - Parameters:
    ///   - source: Откуда брать данные
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func upload<Response>(from source: Source,
                          with request: DynamicRequest,
                          response: Response.Type) -> ProgressPublisher<Response> where Response: CRest.Response
}
#endif
