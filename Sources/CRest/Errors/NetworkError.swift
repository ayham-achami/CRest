//
//  NetworkError.swift
//

import Foundation

/// Ошибка сервера
public protocol ServerError: LocalizedError {

    /// код ошибки
    var code: Int { get }

    /// описание ошибка в текстовом виде
    var message: String { get }
}

public func == (lhs: ServerError, rhs: ServerError) -> Bool {
    lhs.code == rhs.code
}

/// Типы сетевых ошибок
public enum NetworkError: LocalizedError {

    /// Обложка для код ошибки http
    public typealias Code = Int

    /// Ошибка HTTP клиента, зависит от реализации `RestIO`
    case io(String)
    /// Ошибка проверки подлинности сертификата SSL
    case ssl(String)
    /// Ошибка парсинга данных
    case parsing(Data)
    /// Ошибка протокола http
    case http(Code, data: Data? = nil)
    /// Ошибка подключения к интернету
    case notConnected
    /// Подключения к интернету было потеряно
    case connectionLost
    /// Ошибка что-то пошло не так
    case somethingWrong
    /// Серверная ошибка
    case server(ServerError)
    /// Ошибка отмена запроса
    case explicitlyCancelled

    public var errorDescription: String {
        switch self {
        case .io(let reason):
            return "IO error %@".localized(args: reason)
        case .ssl(let reason):
            return "SSL error: \(reason)".localized
        case .parsing:
            return "Incorrect answer format".localized
        case .http(let code, _):
            return "Http error %d %@".localized(args: code, HTTPURLResponse.localizedString(forStatusCode: code))
        case .notConnected:
            return "No internet connection".localized
        case .connectionLost:
            return "Network connection was lost".localized
        case .somethingWrong:
            return "Something went wrong".localized
        case .server(let error):
            return error.message
        case .explicitlyCancelled:
            return "Request has concelled".localized
        }
    }
}

// MARK: - NetworkErrorCode + Equatable
extension NetworkError: Equatable {

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected),
             (.connectionLost, .connectionLost),
             (.somethingWrong, .somethingWrong),
             (.explicitlyCancelled, .explicitlyCancelled):
            return true
        case (.ssl(let lhs), .ssl(let rhs)):
            return lhs == rhs
        case (.io(let lhs), .io(let rhs)):
            return lhs == rhs
        case (.parsing(let lhs), .parsing(let rhs)):
            return lhs == rhs
        case (.server(let lhe), .server(let rhe)):
                return lhe == rhe
        case (.http(let lhc, let lhData), .http(let rhc, let rhData)):
                return lhc == rhc && lhData == rhData
        default:
            return false
        }
    }
}

// MARK: - Error + Cancelled
public extension Error {
    
    var isCancelled: Bool {
        do {
            throw self
        } catch URLError.cancelled {
            return true
        } catch CocoaError.userCancelled {
            return true
        } catch {
        #if os(macOS) || os(iOS) || os(tvOS)
            let pair = { ($0.domain, $0.code) }(error as NSError)
            return ("SKErrorDomain", 2) == pair
        #else
            return false
        #endif
        }
    }
}

// MARK: - Error + Temporary
public extension Error {
    
    /// Временная сетевая ошибка
    var isTemporaryNetworkError: Bool {
        if let sessionFailed {
            return sessionFailed.code == NSURLErrorNotConnectedToInternet ||
                   sessionFailed.code == NSURLErrorNetworkConnectionLost
        }
        if let networkError = self as? NetworkError {
            return networkError == .notConnected || networkError == .connectionLost
        }
        return false
    }
}
