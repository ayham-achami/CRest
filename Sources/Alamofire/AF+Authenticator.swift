//
//  AF+Authenticator.swift
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

import Alamofire
import Foundation

/// Обертка поверх авторизатор `Authenticator`
final class BearerAuthAuthentificatorWrapper: Authenticator {
    
    /// Обертка поверх `AuthenticationCredential`
    struct CredentialWrapper: AuthenticationCredential, BearerCredential {
        
        private let credential: BearerCredential
        
        var access: String {
            credential.access
        }
        
        var isValidated: Bool {
            credential.isValidated
        }
        
        public var requiresRefresh: Bool {
            !self.isValidated
        }
        
        init(_ credential: BearerCredential) {
            self.credential = credential
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
        Task { 
            do {
                let refreshed = try await authenticator.provider.refresh()
                completion(.success(.init(refreshed)))
            } catch {
                completion(.failure(error))
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
    static func encryptorSession(_ session: HandshakeSession) -> Self {
        .init(name: session.headerKey, value: session.id)
    }
}

/// Обертка поверх `Authenticator`
final class HandshakeAuthentificatorWrapper: Authenticator {
    
    /// Обертка поверх `AuthenticationCredential`
    struct SessionWrapper: AuthenticationCredential, HandshakeSession {
        
        private let session: HandshakeSession
        
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
        
        init(_ session: HandshakeSession) {
            self.session = session
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
        Task {
            do {
                let handshake = try await authenticator.provider.handshake()
                completion(.success(.init(handshake)))
            } catch {
                completion(.failure(error))
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
