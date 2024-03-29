//
//  ReachabilityListener.swift
//

import Combine
import Foundation

/// Различные типы соединений
public enum Connection {
    
    /// Неизвестно
    case unknown
    /// Соединение отключено
    case offline
    /// Тип подключения - через Ethernet или WiFi.
    case ethernetOrWiFi
    /// Тип соединения - сотовая связь.
    case cellular
}

/// Наблюдателя состояния сети
public protocol ReachabilityListener: AnyObject {

    /// Доступна ли сеть в настоящее время.
    var isReachable: Bool { get }
    
    /// Текущее состояние сети
    var currentState: Connection { get }
    
    /// Подписать на состояние сети
    /// - Returns: `AnyPublisher<Connection, Never>`
    func subscribeReachabilityState() -> AnyPublisher<Connection, Never>
}
