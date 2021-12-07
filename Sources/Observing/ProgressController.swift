//
//  ProgressController.swift
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

/// Протокол контроля прогресс скачивания
public protocol ProgressController: AnyObject {

    /// Остановить скачивание
    func pauseProgress()

    /// Возобновить скачивание
    func resumeProgress()

    /// Отменить скачивание
    func cancelProgress()
}

public struct ProgressToken<Owner: AnyObject, Argument> {

    /// Уникальный идентификатор
    public let id: String
    /// Уонтроля прогресс скачивания
    public let controller: ProgressController
    /// Наблюдатель прогресса скачивания
    public let observer: ProgressObserver<Owner, Argument>

    /// Инициализация
    ///
    /// - Parameters:
    ///   - id: Идентификатор
    ///   - observer: Контроля прогресс скачивания
    ///   - controller: Наблюдатель прогресса скачивания
    public init(_ id: String,
                _ observer: ProgressObserver<Owner, Argument>,
                _ controller: ProgressController) {
        self.id = id
        self.observer = observer
        self.controller = controller
    }

    /// Инициализация
    ///
    /// - Parameters:
    ///   - observer: Контроля прогресс скачивания
    ///   - controller: Наблюдатель прогресса скачивания
    public init(_ observer: ProgressObserver<Owner, Argument>,
                _ controller: ProgressController) {
        self.init(UUID().uuidString, observer, controller)
    }
}
