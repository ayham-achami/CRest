//
//  Cookies.swift
//

import Alamofire
import Foundation

/// Обертка поверх `Authenticator`
final class CookiesAuthenticatorWrapper: Authenticator {
    
    /// Обертка поверх `AuthenticationCredential`
    struct CredentialWrapper: AuthenticationCredential, CookiesCredential {
        
        private let credential: any CookiesCredential
        
        var cookies: [HTTPCookie] {
            credential.cookies
        }
        
        var requiresRefresh: Bool {
            !isValidatedCredential(self)
        }
        
        private let isValidatedCredential: (any CookiesCredential) -> Bool
        
        init(_ credential: any CookiesCredential, isValidatedCredential: @escaping (any CookiesCredential) -> Bool) {
            self.credential = credential
            self.isValidatedCredential = isValidatedCredential
        }
    }
    
    typealias Credential = CredentialWrapper
    
    private let authenticator: IOCookiesAuthenticator
    
    init(_ authenticator: IOCookiesAuthenticator) {
        self.authenticator = authenticator
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: any Error) -> Bool {
        authenticator.refreshStatusCodes.contains(response.statusCode) && urlRequest != authenticator.refreshRequest
    }
    
    /// URLSession добавит куки самостоятельно
    func apply(_ credential: CredentialWrapper, to urlRequest: inout URLRequest) {}
    
    func refresh(_ credential: CredentialWrapper, for session: Session, completion: @escaping @Sendable (Result<CredentialWrapper, any Error>) -> Void) {
        Task(priority: .high) {
            do {
                completion(
                    .success(
                        .init(
                            try await authenticator.provider.refresh(), // TODO: - надо прокидывать путь из ошибки
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
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: CredentialWrapper) -> Bool {
        authenticator.provider.storage.cookies == credential.cookies
    }
}
