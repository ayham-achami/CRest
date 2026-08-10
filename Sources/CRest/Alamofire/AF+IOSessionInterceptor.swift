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
    static var cookiesAuthentication: IOSessionInterceptor?
    static var secondaryBearerAuthentication: IOSessionInterceptor?
    static var handshakeAuthentication: IOSessionInterceptor?
    static var authStrategyAuthentication: IOSessionInterceptor?
    
    /// Возвращает сессионный интерцептор
    /// - Parameters:
    ///   - orchestrator: Оркестратор авторизации
    ///   - bearer: Авторизация по BearerToken
    ///   - cookies: Авторизация по Cookies
    /// - Returns: `AuthenticationInterceptor<AuthStrategyAuthenticatorWrapper>`
    static func create(orchestrator: IOAuthOrchestrator,
                       bearer: IOBearerAuthenticator,
                       cookies: IOCookiesAuthenticator) -> IOSessionInterceptor {
        let credential: AuthCredential
        switch orchestrator.strategy() {
        case .bearer:
            credential = .token(BearerAuthAuthenticatorWrapper.CredentialWrapper(
                bearer.provider.credential,
                isValidatedCredential: { [weak bearer] credential in
                    bearer?.provider.isValidated(credential: credential) ?? false
                }
            ))
        case .cookie:
            credential = .cookies(CookiesAuthenticatorWrapper.CredentialWrapper(
                cookies.provider.credential,
                isValidatedCredential: { [weak cookies] credential in
                    cookies?.provider.isValidated(credential: credential) ?? false
                })
            )
        }
        return AuthenticationInterceptor<AuthStrategyAuthenticatorWrapper>(
            authenticator: AuthStrategyAuthenticatorWrapper(orchestrator: orchestrator,
                                                            cookiesAuthenticator: .init(cookies),
                                                            bearerAuthenticator: .init(bearer)),
            credential: credential,
        )
    }
    
    /// Возвращает сессионный интерцептор
    /// - Parameter bearer: Контроля статус авторизации по BearerToken
    /// - Returns: `AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>`
    static func create(bearer: IOBearerAuthenticator) -> IOSessionInterceptor {
        AuthenticationInterceptor<BearerAuthAuthenticatorWrapper>(
            authenticator: BearerAuthAuthenticatorWrapper(bearer),
            credential: BearerAuthAuthenticatorWrapper.CredentialWrapper(
                bearer.provider.credential,
                isValidatedCredential: { [weak bearer] credential in
                    bearer?.provider.isValidated(credential: credential) ?? false
                }
            )
        )
    }
    
    /// Возвращает сессионный интерцептор
    /// - Parameter cookies: Аутентификатор использующий Cookies
    /// - Returns: `AuthenticationInterceptor<CookiesAuthenticatorWrapper>`
    static func create(cookies: IOCookiesAuthenticator) -> IOSessionInterceptor {
        AuthenticationInterceptor<CookiesAuthenticatorWrapper>(
            authenticator: CookiesAuthenticatorWrapper(cookies),
            credential: CookiesAuthenticatorWrapper.CredentialWrapper(
                cookies.provider.credential,
                isValidatedCredential: { [weak cookies] credential in
                    cookies?.provider.isValidated(credential: credential) ?? false
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
