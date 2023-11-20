//
//  ObserverProtocol.swift
//

import Foundation

@available(*, deprecated, message: "This feature has be deprecated and will be removed in future release")
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
@available(*, deprecated, message: "This feature has be deprecated and will be removed in future release")
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
