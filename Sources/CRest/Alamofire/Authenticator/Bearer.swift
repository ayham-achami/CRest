//
//  Bearer.swift
//

import Alamofire
import Foundation

/// Обертка поверх авторизатор `Authenticator`
final class BearerAuthAuthenticatorWrapper: Authenticator {
    
    /// Обертка поверх `AuthenticationCredential`
    struct CredentialWrapper: AuthenticationCredential, BearerCredential {
        
        private let credential: any BearerCredential
        
        var access: String {
            credential.access
        }
        
        var requiresRefresh: Bool {
            !isValidatedCredential(self)
        }
        
        private let isValidatedCredential: @Sendable (any BearerCredential) -> Bool
        
        init(_ credential: any BearerCredential, isValidatedCredential: @escaping @Sendable (any BearerCredential) -> Bool) {
            self.credential = credential
            self.isValidatedCredential = isValidatedCredential
        }
    }
    
    typealias Credential = CredentialWrapper
    
    let authenticator: IOBearerAuthenticator
    
    init(_ authenticator: IOBearerAuthenticator) {
        self.authenticator = authenticator
    }
    
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.access))
    }
    
    func refresh(_ credential: Credential, for session: Session, completion: @escaping (Result<Credential, Error>) -> Void) {
        if let credential = try? authenticator.provider.match(credential) {
            completion(
                .success(
                    .init(
                        credential,
                        isValidatedCredential: { [weak authenticator] credential in
                            authenticator?.provider.isValidated(credential: credential) ?? false
                        }
                    )
                )
            )
        } else {
            Task(priority: .high) {
                do {
                    completion(
                        .success(
                            .init(
                                try await authenticator.provider.refresh(),
                                isValidatedCredential: { [weak authenticator] credential in
                                    authenticator?.provider.isValidated(credential: credential) ?? false
                                }
                            )
                        )
                    )
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        authenticator.refreshStatusCodes.contains(response.statusCode) && urlRequest != authenticator.refreshRequest
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        urlRequest.headers.contains(.authorization(bearerToken: credential.access))
    }
}

enum AuthCredential: AuthenticationCredential, Sendable {
    
    case token(BearerAuthAuthenticatorWrapper.CredentialWrapper)
    case cookies(CookiesAuthenticatorWrapper.CredentialWrapper)
    
    var requiresRefresh: Bool {
        switch self {
        case .token(let credential):
            credential.requiresRefresh
        case .cookies(let credential):
            credential.requiresRefresh
        }
    }
}
