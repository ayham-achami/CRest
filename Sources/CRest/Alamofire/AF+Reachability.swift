//
//  AFReachability.swift
//

import Alamofire
import CFoundation
import Combine

/// Объект прослушивает изменения состояние сети
public class AlamofireReachability {
    
    /// Хост наблюдения
    public static var host: String = "apple.com"

    /// Объект прослушивает изменения состояние сети
    public static let shared = AlamofireReachability()

    /// Доступна ли сеть в настоящее время.
    public var isReachable: Bool { manager?.isReachable ?? true }
    
    /// Текущее состояние сети
    public var currentState: Connection { subject.value }

    private var source: ReferenceArray<AnyObject>
    private let manager: NetworkReachabilityManager?
    private let subject = CurrentValueSubject<Connection, Never>(.unknown)

    /// Инициализация
    private init() {
        source = []
        manager = NetworkReachabilityManager(host: Self.host)
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
    
    /// подписать на состояние сети
    /// - Returns: `AnyPublisher<Connection, Never>`
    func subscribeReachabilityState() -> AnyPublisher<Connection, Never> {
        subject.eraseToAnyPublisher()
    }

    /// Вызывается когда меняется состояние сети
    /// - Parameter state: Новое состояние
    private func notifyReachabilityChanged(_ state: NetworkReachabilityManager.NetworkReachabilityStatus) {
        subject.send(state.connection)
        source
            .cleanup()
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
    
    var currentState: Connection { AlamofireReachability.shared.currentState }

    func startWatchReachabilityState() {
        AlamofireReachability.shared.addListener(self)
    }

    func stopWatchReachabilityState() {
        AlamofireReachability.shared.removeListener(self)
    }
    
    func subscribeReachabilityState() -> AnyPublisher<Connection, Never> {
        AlamofireReachability.shared.subscribeReachabilityState()
    }
}
