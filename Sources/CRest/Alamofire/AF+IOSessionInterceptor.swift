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
    
    static var bearerAuthentication: AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>?
    static var handshakeAuthentication: AuthenticationInterceptor<HandshakeAuthentificatorWrapper>?
    
    /// Возвращает сессионный интерцептор
    /// - Parameter bearer: Контроля статус авторизации по BearerToken
    /// - Returns: `AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>`
    static func create(bearer: IOBearerAuthenticator) -> AuthenticationInterceptor<BearerAuthAuthentificatorWrapper> {
        AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>(
            authenticator: BearerAuthAuthentificatorWrapper(bearer),
            credential: BearerAuthAuthentificatorWrapper.CredentialWrapper(bearer.provider.credential)
        )
    }
    
    /// Возвращает сессионный интерцептор
    /// - Parameter handshake: Авторизации на уровне рукопожатия
    /// - Returns: `AuthenticationInterceptor<HandshakeAuthentificatorWrapper>`
    static func create(handshake: IOHandshakeAuthenticator) -> AuthenticationInterceptor<HandshakeAuthentificatorWrapper> {
        AuthenticationInterceptor<HandshakeAuthentificatorWrapper>(
            authenticator: HandshakeAuthentificatorWrapper(handshake),
            credential: HandshakeAuthentificatorWrapper.SessionWrapper(handshake.provider.session)
        )
    }
}
