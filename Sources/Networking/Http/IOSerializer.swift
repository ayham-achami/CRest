//
//  IOSerializer.swift
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
    func encountered(_ error: Error, for request: URLRequest?, and response: HTTPURLResponse?, data: Data?) -> Error
}

// MARK: - IOErrorSerializationController + Default
public extension IOErrorSerializationController {
    
    func encountered(_ error: Error, for request: URLRequest?, and response: HTTPURLResponse?, data: Data?) -> Error {
        return error
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
@frozen public struct DefaultSerializer: IOSerializer {}
