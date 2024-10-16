//
//  IOSessionInterceptor.swift
//

import Alamofire
import Foundation

// MARK: - IOSessionInterceptor + AF
extension IOSessionInterceptor {
    
    var afInterceptor: Alamofire.RequestInterceptor {
        guard
            let authenticator = self as? Alamofire.RequestInterceptor
        else { preconditionFailure("IOSessionInterceptor must be an RequestInterceptor") }
        return authenticator
    }
}

// MARK: - AuthenticationInterceptor + IOSessionInterceptor
extension AuthenticationInterceptor: IOSessionInterceptor {}

// MARK: - RestIOSession
extension RestIOSession {
    
    static var bearerAuthentication: IOSessionInterceptor?
    static var handshakeAuthentication: IOSessionInterceptor?
    
    /// Возвращает сессионный интерцептор
    /// - Parameter bearer: Контроля статус авторизации по BearerToken
    /// - Returns: `AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>`
    static func create(bearer: IOBearerAuthenticator) -> IOSessionInterceptor {
        AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>(
            authenticator: BearerAuthAuthentificatorWrapper(bearer),
            credential: BearerAuthAuthentificatorWrapper.CredentialWrapper(
                bearer.provider.credential,
                isValidatedCredential: { [weak bearer] credential in
                    bearer?.provider.isValidated(credential: credential) ?? false
                }
            )
        )
    }
    
    /// Возвращает сессионный интерцептор
    /// - Parameter handshake: Авторизации на уровне рукопожатия
    /// - Returns: `AuthenticationInterceptor<HandshakeAuthentificatorWrapper>`
    static func create(handshake: IOHandshakeAuthenticator) -> IOSessionInterceptor {
        AuthenticationInterceptor<HandshakeAuthentificatorWrapper>(
            authenticator: HandshakeAuthentificatorWrapper(handshake),
            credential: HandshakeAuthentificatorWrapper.SessionWrapper(
                handshake.provider.session,
                isValidatedCredential: { [weak handshake] session in
                    handshake?.provider.isValidated(credential: session) ?? false
                }
            )
        )
    }
}
