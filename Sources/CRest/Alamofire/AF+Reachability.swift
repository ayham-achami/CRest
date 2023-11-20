//
//  AFReachability.swift
//

import Alamofire
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

    private let manager: NetworkReachabilityManager?
    private let subject = CurrentValueSubject<Connection, Never>(.unknown)

    /// Инициализация
    private init() {
        manager = NetworkReachabilityManager(host: Self.host)
        manager?.startListening(onUpdatePerforming: notifyReachabilityChanged(_:))
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
    
    func subscribeReachabilityState() -> AnyPublisher<Connection, Never> {
        AlamofireReachability.shared.subscribeReachabilityState()
    }
}
