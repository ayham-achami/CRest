//
//  Handshake.swift
//

import Alamofire
import Foundation

// MARK: - HTTPHeader + Encryptor
extension HTTPHeader {
    
    /// Хедар для хандшека
    /// - Parameter session: Сессия хандшека
    /// - Returns: `HTTPHeader`
    static func encryptorSession(_ session: any HandshakeSession) -> Self {
        .init(name: session.headerKey, value: session.id)
    }
}

/// Обертка поверх `Authenticator`
final class HandshakeAuthentificatorWrapper: Authenticator {
    
    /// Обертка поверх `AuthenticationCredential`
    struct SessionWrapper: AuthenticationCredential, HandshakeSession {
        
        private let session: any HandshakeSession
        
        var id: String {
            session.id
        }
        
        var headerKey: String {
            session.headerKey
        }
        
        var requiresRefresh: Bool {
            !isValidatedCredential(self)
        }
        
        private let isValidatedCredential: @Sendable (any HandshakeSession) -> Bool
        
        init(_ session: any HandshakeSession, isValidatedCredential: @escaping @Sendable (any HandshakeSession) -> Bool) {
            self.session = session
            self.isValidatedCredential = isValidatedCredential
        }
    }
    
    typealias Credential = SessionWrapper
    
    let authenticator: IOHandshakeAuthenticator
    
    init(_ authenticator: IOHandshakeAuthenticator) {
        self.authenticator = authenticator
    }
    
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.encryptorSession(credential))
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
                                try await authenticator.provider.handshake(),
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
        authenticator.handshakeStatusCodes.contains(response.statusCode) && urlRequest != authenticator.handshakeRequest
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        urlRequest.headers.contains(.encryptorSession(credential))
    }
}
