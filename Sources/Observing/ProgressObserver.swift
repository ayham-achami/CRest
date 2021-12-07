//
//  ProgressObserver.swift
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

/// Наблюдатель прогресса скачивания
public final class ProgressObserver<Owner: AnyObject, Argument> {

    /// Источник контроля
    private let source: ObserverSource<Owner, Argument>

    /// Инициализация наблюдателя
    ///
    /// - Parameters:
    ///   - owner: объект создающий запрос (делегат)
    ///   - responseType: тип ожидаемого ответа
    public init(owner: Owner, argumentType: Argument.Type) {
        source = ObserverSource(owner: owner, argumentType: argumentType)
    }

    /// Реализация замыкания успеха
    ///
    /// - Parameter done: замыкание успеха
    /// - Returns: наблюдатель запроса
    public func done(_ done: @escaping ((Owner, Argument) throws -> Void)) -> Self {
        source.done = done
        return self
    }

    /// Реализация замыкания обработки ошибки
    ///
    /// - Parameter `catch`: замыкание обработки ошибки
    /// - Returns: наблюдатель за запрос
    @discardableResult
    public func `catch`(_ `catch`: @escaping (Owner, Error) -> Void) -> Self {
        source.catch = `catch`
        return self
    }

    /// Реализация замыкания изменения прогресса (загрузки, выгрузки)
    ///
    /// - Parameter progress: Объект, который передает текущий прогресс для данной задачи
    /// - Returns: Наблюдатель за запрос
    public func progress(_ progress: @escaping ((Owner, Progress) throws -> Void)) -> Self {
        source.progress = progress
        return self
    }

    /// вызвать нужное замыкание по заданному аргументу
    /// - Parameter argument: аргумент
    public func invoke(_ argument: @autoclosure () throws -> Any) {
        do {
            source.invoke(try argument())
        } catch {
            source.invoke(error)
        }
    }
}
