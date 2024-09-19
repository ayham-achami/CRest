//
//  Observer.swift
//

import Foundation

// Наблюдатель
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public final class Observer<Owner: AnyObject, Argument> {

    /// Источник контроля
    private let source: ObserverSource<Owner, Argument>

    /// Инициализация наблюдателя
    /// - Parameters:
    ///   - owner: объект создающий запрос (делегат)
    ///   - responseType: тип ожидаемого ответа
    public init(owner: Owner, argumentType: Argument.Type) {
        source = ObserverSource(owner: owner, argumentType: argumentType)
    }

    /// Реализация замыкания успеха
    /// - Parameter done: замыкание успеха
    /// - Returns: наблюдатель запроса
    public func done(_ done: @escaping ((Owner, Argument) throws -> Void)) -> Self {
        source.done = done
        return self
    }

    /// Реализация замыкания обработки ошибки
    /// - Parameter `catch`: замыкание обработки ошибки
    /// - Returns: наблюдатель за запрос
    @discardableResult
    public func `catch`(_ `catch`: @escaping (Owner, Error) -> Void) -> Self {
        source.catch = `catch`
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
