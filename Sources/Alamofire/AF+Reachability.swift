//
//  AFReachability.swift
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

import Alamofire
import CFoundation

/// Объект прослушивает изменения стостяние сети
public class AlamofireReachability {

    /// Объект прослушивает изменения стостяние сети
    public static let shared = AlamofireReachability()

    /// Доступна ли сеть в настоящее время.
    public var isReachable: Bool { manager?.isReachable ?? true }

    private var source: ReferenceArray<AnyObject>
    private let manager: NetworkReachabilityManager?

    /// Инициализация
    private init() {
        source = []
        manager = NetworkReachabilityManager(host: "apple.com")
        manager?.startListening(onUpdatePerforming: notifyReachabilityChanged(_:))
    }

    /// Добавить прослушивателя
    /// - Parameter listener: Прослушиватель
    public func addListener(_ listener: ReachabilityListener) {
        source.append(listener)
    }

    /// Убрать прослушивателя
    /// - Parameter listener: Прослушиватель
    public func removeListener(_ listener: ReachabilityListener) {
        source.remove(listener)
    }

    /// Вызывается когда меняется состояние сети
    /// - Parameter state: Новое состояние
    private func notifyReachabilityChanged(_ state: NetworkReachabilityManager.NetworkReachabilityStatus) {
        source.cleanup()
            .compactMap { $0 as? ReachabilityListener }
            .forEach { $0.networkReachabilityStateDidChange(state.connection) }
    }
}

// MARK: NetworkReachabilityStatus + Connection
private extension NetworkReachabilityManager.NetworkReachabilityStatus {

    var connection: Connection {
        switch self {
        case let .reachable(state):
            switch state {
            case .cellular:
                return .cellular
            case .ethernetOrWiFi:
                return .ethernetOrWiFi
            }
        case .notReachable:
            return .offline
        case .unknown:
            return .unknown
        }
    }
}

// MARK: - ReachabilityListener + Default
public extension ReachabilityListener {

    var isReachable: Bool { AlamofireReachability.shared.isReachable }

    func startWatchReachabilityState() {
        AlamofireReachability.shared.addListener(self)
    }

    func stopWatchReachabilityState() {
        AlamofireReachability.shared.removeListener(self)
    }
}
