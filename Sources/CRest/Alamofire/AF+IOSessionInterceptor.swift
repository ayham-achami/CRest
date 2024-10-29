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

// MARK: - RestIOSession + Repository
extension RestIOSession {
    
    /// <#Description#>
    final class Repository: @unchecked Sendable {
        
        private let unfairLock: os_unfair_lock_t
        private var bearer: IOSessionInterceptor?
        private var handshake: IOSessionInterceptor?
        
        init() {
            unfairLock = .allocate(capacity: 1)
            unfairLock.initialize(to: os_unfair_lock())
        }

        deinit {
            unfairLock.deinitialize(count: 1)
            unfairLock.deallocate()
        }
        
        /// <#Description#>
        /// - Parameter bearer: <#bearer description#>
        /// - Returns: <#description#>
        func bearerAuthentication(bearer: IOBearerAuthenticator) -> IOSessionInterceptor {
            around {
                if let bearer = $0.bearer {
                    return bearer
                } else {
                    let bearer = $0.create(bearer: bearer)
                    $0.bearer = bearer
                    return bearer
                }
            }
        }
        
        /// <#Description#>
        /// - Parameter handshake: <#handshake description#>
        /// - Returns: <#description#>
        func handshakeAuthentication(handshake: IOHandshakeAuthenticator) -> IOSessionInterceptor {
            around {
                if let handshake = $0.handshake {
                    return handshake
                } else {
                    let handshake = $0.create(handshake: handshake)
                    $0.handshake = handshake
                    return handshake
                }
            }
        }
        
        /// Возвращает сессионный интерцептор
        /// - Parameter bearer: Контроля статус авторизации по BearerToken
        /// - Returns: `AuthenticationInterceptor<BearerAuthAuthentificatorWrapper>`
        private func create(bearer: IOBearerAuthenticator) -> IOSessionInterceptor {
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
        private func create(handshake: IOHandshakeAuthenticator) -> IOSessionInterceptor {
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
        
        /// <#Description#>
        /// - Parameter atomic: <#atomic description#>
        /// - Returns: <#description#>
        private func around(_ atomic: (Repository) -> IOSessionInterceptor) -> IOSessionInterceptor {
            os_unfair_lock_lock(unfairLock)
            defer { os_unfair_lock_unlock(unfairLock) }
            return atomic(self)
        }
    }
}
