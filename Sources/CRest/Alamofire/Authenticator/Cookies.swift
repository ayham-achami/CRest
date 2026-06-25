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
        
        private let isValidatedCredential: @Sendable (any CookiesCredential) -> Bool
        
        init(_ credential: any CookiesCredential, isValidatedCredential: @escaping @Sendable (any CookiesCredential) -> Bool) {
            self.credential = credential
            self.isValidatedCredential = isValidatedCredential
        }
    }
    
    typealias Credential = CredentialWrapper
    
    private let authenticator: IOCookiesAuthenticator
    
    var credential: CredentialWrapper {
        .init(authenticator.provider.credential) { [weak authenticator] credential in
            authenticator?.provider.isValidated(credential: credential) ?? false
        }
    }
    
    init(_ authenticator: IOCookiesAuthenticator) {
        self.authenticator = authenticator
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: any Error) -> Bool {
        guard
            let url = urlRequest.url,
            authenticator.refreshStatusCodes.contains(response.statusCode),
            !authenticator.refreshPaths.contains(where: { url.lastPathComponent.contains($0) })
        else { return false }
        return true
    }
    
    /// URLSession добавит куки самостоятельно
    func apply(_ credential: CredentialWrapper, to urlRequest: inout URLRequest) {}
    
    func refresh(_ credential: CredentialWrapper, for session: Session, completion: @escaping @Sendable (Result<CredentialWrapper, any Error>) -> Void) {
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
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: CredentialWrapper) -> Bool {
        /// Возвращается true, так как нет ручной установки Cookies
        true
    }
}
