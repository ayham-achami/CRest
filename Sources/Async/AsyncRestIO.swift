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
