//
//  Invocation.swift
//

import Foundation

/// Исполняемый объект
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public protocol Invocation {

    /// Выполнить любое значение
    /// - Parameter argument: любое значнине
    func invoke(_ argument: Any)
}

// MARK: - Invocation + ObserverProtocol
@available(*, deprecated, message: "This feature has been deprecated and will be removed in future release")
public extension Invocation where Self: ObserverProtocol {

    func invoke(_ argument: Any) {
        switch argument {
        case let value as Argument:
            tryDone(value)
        case let progress as Progress:
            tryProgress(progress)
        // add new closure invocation
        case let error as Error:
            tryCatch(error)
        default:
            preconditionFailure("Couldn't to invoke with \(String(describing: type(of: argument))) value \(argument)")
        }
    }
}
