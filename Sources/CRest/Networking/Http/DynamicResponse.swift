//
//  DynamicResponse.swift
//

import Foundation

/// Динамический ответ
@frozen public struct DynamicResponse<Response: CRest.Response> {
    
    /// Состояние ответа
    public enum State {
        
        /// Ошибочный
        case invalid(Response)
        /// Успешный
        case actually(DynamicResponse<Response>)
    }
    
    /// URL запроса
    public let url: URL?
    /// Код ответа
    public let statusCode: Int
    /// Ответ
    public let response: Response
    /// Загловки ответа
    public let allHeaderFields: [AnyHashable: Any]
    
    /// Состояние ответа
    public var state: State {
        guard url != nil else { return .invalid(response) }
        return .actually(self)
    }
    
    /// Инициализация
    /// - Parameters:
    ///   - response: Ответ
    ///   - URLResponse: URL ответ
    public init(_ response: Response, _ URLResponse: HTTPURLResponse?) {
        self.response = response
        if let URLResponse = URLResponse {
            url = URLResponse.url
            statusCode = URLResponse.statusCode
            allHeaderFields = URLResponse.allHeaderFields
        } else {
            url = nil
            statusCode = -1
            allHeaderFields = [:]
        }
    }
}
