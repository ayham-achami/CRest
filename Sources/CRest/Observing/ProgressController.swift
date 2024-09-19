//
//  ProgressController.swift
//

import Foundation

/// Протокол контроля прогресс загрузки
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public protocol ProgressController: AnyObject {

    /// Остановить загрузки
    func pauseProgress()

    /// Возобновить загрузки
    func resumeProgress()

    /// Отменить загрузки
    func cancelProgress()
}

@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public struct ProgressToken<Owner: AnyObject, Argument> {

    /// Уникальный идентификатор
    public let id: String
    /// Контролер прогресса загрузки
    public let controller: ProgressController
    /// Наблюдатель прогресса загрузки
    public let observer: ProgressObserver<Owner, Argument>

    /// Инициализация
    /// - Parameters:
    ///   - id: Идентификатор
    ///   - observer: Контроля прогресс загрузки
    ///   - controller: Наблюдатель прогресса загрузки
    public init(_ id: String,
                _ observer: ProgressObserver<Owner, Argument>,
                _ controller: ProgressController) {
        self.id = id
        self.observer = observer
        self.controller = controller
    }

    /// Инициализация
    /// - Parameters:
    ///   - observer: Контроля прогресс загрузки
    ///   - controller: Наблюдатель прогресса загрузки
    public init(_ observer: ProgressObserver<Owner, Argument>,
                _ controller: ProgressController) {
        self.init(UUID().uuidString, observer, controller)
    }
}
