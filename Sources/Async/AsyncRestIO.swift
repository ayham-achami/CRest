//
//  AsyncRestIO.swift
//  CFoundation
//
//  Created by Aleksandr Miaots on 15.11.2021.
//  Copyright © 2021 Cometrica. All rights reserved.
//

#if compiler(>=5.5.2) && canImport(_Concurrency)
import Foundation

/// Http клиент
@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
public protocol AsyncRestIO: AnyObject {
    
    typealias Destination = URL
    typealias Source = URL
    
    /// Инициализация
    /// - Parameter configuration: Общие настройки REST клиента
    init(_ configuration: RestIOConfiguration)
    
    /// Выполняет рестовый http запроса
    /// - Parameters:
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func perform<Response>(_ request: DynamicRequest, response: Response.Type) async throws -> Response where Response: CRest.Response
    
    /// Скачает данные и сохраняет их на диске
    /// - Parameters:
    ///   - owner: Создатель запроса
    ///   - destination: Куда сохранить
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func download<Owner, Response>(for owner: Owner,
                                   into destination: Destination,
                                   with request: DynamicRequest,
                                   response: Response.Type) -> ProgressToken<Owner, Response> where Owner: AnyObject,
                                                                                                    Response: CRest.Response
    
    /// Выгружает данные на сервер из указанного источника
    /// - Parameters:
    ///   - owner: Создатель запроса
    ///   - source: Откуда брать данные
    ///   - request: Динамический запрос
    ///   - response: Тип ответа
    func upload<Owner, Response>(for owner: Owner,
                                 from source: Source,
                                 with request: DynamicRequest,
                                 response: Response.Type) -> ProgressToken<Owner, Response> where Owner: AnyObject,
                                                                                                  Response: CRest.Response
}
#endif
