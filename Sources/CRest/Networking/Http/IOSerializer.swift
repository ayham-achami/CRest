//
//  IOSerializer.swift
//

import Foundation

/// Протокол обработки ошибки происходящей при стерилизации ответа
public protocol IOErrorSerializationController {
    
    /// Обработка ошибки происходящей при сериализации ответа
    /// - Parameters:
    ///   - error: Обишка
    ///   - request: Запрос
    ///   - response: Ответ
    ///   - data: Байты ответа
    /// - Returns: Ошибка
    @available(*, deprecated, renamed: "encountered(error:request:response:decoder:data:)", message: "This method not invoked more")
    func encountered(_ error: Error, for request: URLRequest?, and response: HTTPURLResponse?, data: Data?) -> Error
    
    /// Обработка ошибки происходящей при сериализации ответа
    /// - Parameters:
    ///   - error: Обишка
    ///   - request: Запрос
    ///   - response: Ответ
    ///   - decoder: Дикодер ответа
    ///   - data: Байты ответа
    /// - Returns: Ошибка
    func encountered(_ error: Error, _ request: URLRequest?, _ response: HTTPURLResponse?, _ decoder: JSONDecoder, _ data: Data?) -> Error
}

// MARK: - IOErrorSerializationController + Default
public extension IOErrorSerializationController {
    
    @available(*, deprecated, renamed: "encountered(error:request:response:decoder:data:)", message: "This method not invoked more")
    func encountered(_ error: Error, for request: URLRequest?, and response: HTTPURLResponse?, data: Data?) -> Error {
        error
    }
    
    func encountered(_ error: Error,
                     _ request: URLRequest?,
                     _ response: HTTPURLResponse?,
                     _ decoder: JSONDecoder,
                     _ data: Data?) -> Error {
        error
    }
}

/// Протокол контроля ответа (обработка ответа на уровне байтов)
public protocol HTTPBodyController {
    
    /// Контроля ответа
    /// - Parameter body: ответ
    /// - Returns: `Data`
    func didRequestProcessing(_ body: Data) throws -> Data
}

// MARK: - HTTPBodyController + Default
public extension HTTPBodyController {

    func didRequestProcessing(_ body: Data) throws -> Data {
        body
    }
}

/// Протокол сериализации ответа
public protocol IOResponseSerializer: HTTPBodyController, IOErrorSerializationController {
    
    /// Сериализации ответа
    /// - Parameters:
    ///   - data: Байты ответа
    ///   - decoder: Дикодер ответа
    ///   - request: Запрос
    ///   - response: Ответ
    /// - Returns: Новый объект после сериализации
    func serialize<T>(_ data: Data,
                      _ decoder: JSONDecoder,
                      _ request: URLRequest?,
                      _ response: HTTPURLResponse?) throws -> T where T: Response
}

// MARK: - IOResponseSerializer + Default
public extension IOResponseSerializer {

    func serialize<T>(_ data: Data,
                      _ decoder: JSONDecoder,
                      _ request: URLRequest?,
                      _ response: HTTPURLResponse?) throws -> T where T: Response {
        try decoder.decode(T.self, from: try didRequestProcessing(data))
    }
}

/// Протокол сериализации ответа для запросов скачивания
public protocol IODownloadResponseSerializer: HTTPBodyController, IOErrorSerializationController {
    
    /// Сериализации файла например расшифровать
    /// - Parameters:
    ///   - fileURL: Ссылка на скачанный файл
    ///   - request: Запрос
    ///   - response: Ответ
    func serialize(_ fileURL: URL,
                   _ request: URLRequest?,
                   _ response: HTTPURLResponse?) throws
    
    /// Сериализации ответа
    /// - Parameters:
    ///   - fileURL: Ссылка на скачанный файл
    ///   - decoder: Дикодер ответа
    ///   - request: Запрос
    ///   - response: Ответ
    /// - Returns: Новый объект после сериализации
    func serialize<T>(_ fileURL: URL,
                      _ decoder: JSONDecoder,
                      _ request: URLRequest?,
                      _ response: HTTPURLResponse?) throws -> T where T: Response
}

// MARK: - IODownloadResponseSerializer + Default
public extension IODownloadResponseSerializer where Self: IOSerializer {

    func serialize(_ fileURL: URL,
                   _ request: URLRequest?,
                   _ response: HTTPURLResponse?) throws {}
    
    func serialize<T>(_ fileURL: URL,
                      _ decoder: JSONDecoder,
                      _ request: URLRequest?,
                      _ response: HTTPURLResponse?) throws -> T where T: Response {
        try serialize(try Data(contentsOf: fileURL), decoder, request, response)
    }
}

/// Протокол сериализации ответа
public protocol IOSerializer: IOResponseSerializer & IODownloadResponseSerializer {}

/// Сериализатор по умолчанию
@frozen public struct DefaultSerializer: IOSerializer {
    
    public init() {}
}
