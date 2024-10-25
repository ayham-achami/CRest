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
    case server(any ServerError)
    /// Ошибка отмена запроса
    case explicitlyCancelled
    /// Временная сетевая ошибка
    case temporaryNetworkError

    public var errorDescription: String {
        switch self {
        case .io(let reason):
            "IO error %@".localized(args: reason)
        case .ssl(let reason):
            "SSL error: \(reason)".localized
        case .parsing:
            "Incorrect answer format".localized
        case .http(let code, _):
            "Http error %d %@".localized(args: code, HTTPURLResponse.localizedString(forStatusCode: code))
        case .notConnected:
            "No internet connection".localized
        case .connectionLost:
            "Network connection was lost".localized
        case .somethingWrong:
            "Something went wrong".localized
        case .server(let error):
            error.message
        case .explicitlyCancelled:
            "Request has concelled".localized
        case .temporaryNetworkError:
            "Temporary network error".localized
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
            return lhe.code == rhe.code
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
            sessionFailed.code == NSURLErrorNotConnectedToInternet || sessionFailed.code == NSURLErrorNetworkConnectionLost
        } else if let networkError = self as? NetworkError {
            networkError == .notConnected || networkError == .connectionLost || networkError == .temporaryNetworkError
        } else {
            false
        }
    }
}
