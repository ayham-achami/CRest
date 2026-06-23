//
//  AuthStrategy.swift
//

import Alamofire
import Foundation

final class AuthStrategyAuthenticatorWrapper: Authenticator {
    
    typealias Credential = AuthCredential
    
    private let orchestrator: IOAuthOrchestrator
    private let cookiesAuthenticator: CookiesAuthenticatorWrapper
    private let bearerAuthenticator: BearerAuthAuthenticatorWrapper
    
    init(orchestrator: IOAuthOrchestrator,
         cookiesAuthenticator: CookiesAuthenticatorWrapper,
         bearerAuthenticator: BearerAuthAuthenticatorWrapper) {
        self.orchestrator = orchestrator
        self.bearerAuthenticator = bearerAuthenticator
        self.cookiesAuthenticator = cookiesAuthenticator
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: any Error) -> Bool {
        switch orchestrator.strategy() {
        case .bearer:
            bearerAuthenticator.didRequest(urlRequest, with: response, failDueToAuthenticationError: error)
        case .cookie:
            cookiesAuthenticator.didRequest(urlRequest, with: response, failDueToAuthenticationError: error)
        }
    }
    
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        switch orchestrator.strategy() {
        case .bearer:
            guard case let .token(tokenCredential) = credential else { return }
            bearerAuthenticator.apply(tokenCredential, to: &urlRequest)
        case .cookie:
            guard case let .cookies(cookiesCredential) = credential else { return }
            cookiesAuthenticator.apply(cookiesCredential, to: &urlRequest)
        }
    }
    
    func refresh(_ credential: Credential, for session: Session, completion: @escaping @Sendable (Result<Credential, any Error>) -> Void) {
        switch orchestrator.strategy() {
        case .bearer:
            guard case let .token(tokenCredential) = credential else {
                completion(.success(credential))
                return
            }
            bearerAuthenticator.refresh(tokenCredential, for: session) { result in
                completion(result.map { .token($0) })
            }
        case .cookie:
            guard case let .cookies(cookiesCredential) = credential else {
                completion(.success(credential))
                return
            }
            cookiesAuthenticator.refresh(cookiesCredential, for: session) { result in
                completion(result.map { .cookies($0) })
            }
        }
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        switch orchestrator.strategy() {
        case .bearer:
            guard case let .token(tokenCredential) = credential else { return false }
            return bearerAuthenticator.isRequest(urlRequest, authenticatedWith: tokenCredential)
        case .cookie:
            guard case let .cookies(cookiesCredential) = credential else { return false }
            return cookiesAuthenticator.isRequest(urlRequest, authenticatedWith: cookiesCredential)
        }
    }
}
