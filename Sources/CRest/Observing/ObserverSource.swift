//
//  ObserverSource.swift
//

import Foundation

/// Источник контроля
public final class ObserverSource<Owner: AnyObject, Argument>: ObserverProtocol, Invocation {

    public typealias Owner = Owner
    public typealias Argument = Argument

    public var lock = NSLock()
    public var `catch`: ((Owner, Error) -> Void)?
    public var done: ((Owner, Argument) throws -> Void)?
    public var progress: ((Owner, Progress) throws -> Void)?

    public weak var owner: Owner?

    required public init(owner: Owner, argumentType: Argument.Type) {
        self.owner = owner
    }
}
