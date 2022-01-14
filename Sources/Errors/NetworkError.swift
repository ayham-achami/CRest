//
//  NetworkError.swift
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

import Foundation

/// Ошибка сервера
public protocol ServerError: LocalizedError {

    /// код ошибки
    var code: Int { get }

    /// описание ошибка в текстовом виде
    var message: String { get }
}

public func == (lhs: ServerError, rhs: ServerError) -> Bool {
    return lhs.code == rhs.code
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
