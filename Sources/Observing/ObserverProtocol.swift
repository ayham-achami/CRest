//
//  ObserverProtocol.swift
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

public protocol ObserverProtocol: AnyObject {

    associatedtype Argument
    associatedtype Owner: AnyObject

    /// Управление потоков
    var lock: NSLock { get }

    /// Объект создающий запрос (делегат)
    var owner: Owner? { get set}

    /// Замыкание успеха
    var done: ((Owner, Argument) throws -> Void)? { get set }

    /// Замыкание обработки ошибки
    var `catch`: ((Owner, Error) -> Void)? { get set }

    /// Замыкание прогресс скачивания
    var progress: ((Owner, Progress) throws -> Void)? { get set }

    /// Инициализация наблюдателя
    ///
    /// - Parameters:
    ///   - owner: объект создающий запрос (делегат)
    ///   - responseType: тип ожидаемого ответа
    init(owner: Owner, argumentType: Argument.Type)

    /// Попробовать выполнить замыкание успеха
    ///
    /// - Parameter response: ожидаемый объект
    func tryDone(_ argument: Argument)

    /// Попробовать выполнить замыкание прогресс загрузки
    ///
    /// - Parameter progress: Объект, который передает текущий прогресс для данной задачи
    func tryProgress(_ progress: Progress)

    /// Попробовать выполнить замыкание обработки ошибки
    ///
    /// - Parameters:
    func tryCatch(_ error: Error)

    /// выполняет любое замыкание наблюдателя
    /// - Parameter expression: замыкание
    func perform(_ expression: @autoclosure () throws -> Void?)
}

// MARK: - ObserverProtocol + Default
public extension ObserverProtocol {

    func tryDone(_ argument: Argument) {
        guard let owner = owner else { return }
        perform(try done?(owner, argument))
    }

    func tryProgress(_ progress: Progress) {
        guard let owner = owner else { return }
        perform(try self.progress?(owner, progress))
    }

    func tryCatch(_ error: Error) {
       guard let owner = owner else { return }
       `catch`?(owner, error)
    }

    func perform(_ expression: @autoclosure () throws -> Void?) {
        defer {
            lock.unlock()
        }; do {
            lock.lock()
            try expression()
        } catch {
            guard let owner = owner else { return }
            `catch`?(owner, error)
        }
    }
}
