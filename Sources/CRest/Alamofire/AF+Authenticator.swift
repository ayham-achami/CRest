//
//  AF+Authenticator.swift
//

import Alamofire
import Foundation

/// Обертка поверх авторизатор `Authenticator`
final class BearerAuthAuthentificatorWrapper: Authenticator {
    
    /// Обертка поверх `AuthenticationCredential`
    struct CredentialWrapper: AuthenticationCredential, BearerCredential {
        
        private let credential: any BearerCredential
        
        var access: String {
            credential.access
        }
        
        var isValidated: Bool {
            isValidatedCredential(self)
        }
        
        public var requiresRefresh: Bool {
            !isValidated
        }
        
        private let isValidatedCredential: (any BearerCredential) -> Bool
        
        init(_ credential: any BearerCredential, isValidatedCredential: @escaping (any BearerCredential) -> Bool) {
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
        
        var isValidated: Bool {
            session.isValidated
        }
        
        public var requiresRefresh: Bool {
            !self.isValidated
        }
        
        private let isValidatedCredential: (any HandshakeSession) -> Bool
        
        init(_ session: any HandshakeSession, isValidatedCredential: @escaping (any HandshakeSession) -> Bool) {
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
                    let handshake = try await authenticator.provider.handshake()
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
