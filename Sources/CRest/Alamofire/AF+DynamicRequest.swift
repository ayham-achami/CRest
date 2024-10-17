//
//  AF+DynamicRequest.swift
//

import Alamofire
import Foundation

// MARK: - CRest.Empty + Alamofire
extension CRest.Empty: EmptyResponse {
    
    public static var value: Self {
        .init()
    }
    
    public static func emptyValue() -> Self {
        .value
    }
}

// MARK: - DynamicRequest + Interceptor
extension DynamicRequest {

    var afInterceptor: Alamofire.Interceptor {
        .init(interceptors: interceptors.map(afInterceptors(_:)) + afSessionInterceptors())
    }
    
    private func afSessionInterceptors() -> [RequestInterceptor] {
        guard let sessionInterceptor else { return [] }
        guard
            let sessionInterceptor = sessionInterceptor as? RequestInterceptor
        else { preconditionFailure("SessionInterceptor must be an instance of RequestInterceptor") }
        return [sessionInterceptor]
    }
    
    private func afInterceptors(_ interceptor: IOInterceptor) -> Alamofire.RequestInterceptor {
        switch interceptor {
        case let authenticator as IOBearerAuthenticator:
            return wrapping(bearer: authenticator)
        case let authenticator as IOHandshakeAuthenticator:
            return wrapping(encryptor: authenticator)
        case let requestInterceptor as RequestInterceptor:
            return requestInterceptor
        default:
            return wrapping(interceptor: interceptor)
        }
    }
    
    private func wrapping(bearer: IOBearerAuthenticator) -> RequestInterceptor {
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
    
    private func wrapping(encryptor: IOHandshakeAuthenticator) -> RequestInterceptor {
        AuthenticationInterceptor<HandshakeAuthentificatorWrapper>(
            authenticator: HandshakeAuthentificatorWrapper(encryptor),
            credential: HandshakeAuthentificatorWrapper.SessionWrapper(
                encryptor.provider.session,
                isValidatedCredential: { [weak encryptor] session in
                    encryptor?.provider.isValidated(credential: session) ?? false
                }
            )
        )
    }
    
    private func wrapping(interceptor: IOInterceptor) -> RequestInterceptor {
        InterceptorWrapper(interceptor)
    }
}

// MARK: - DynamicRequest + Alamofire
extension DynamicRequest {
    
    var afHeders: Alamofire.HTTPHeaders {
        HTTPHeaders(headers)
    }

    var afMethod: Alamofire.HTTPMethod {
        HTTPMethod(rawValue: method.rawValue)
    }
    
    var afJSONEncoder: Alamofire.JSONParameterEncoder {
        JSONParameterEncoder(encoder: encoder)
    }
    
    var afEmptyRequestMethods: Set<Alamofire.HTTPMethod> {
        Set(emptyRequestMethods.compactMap { .init(rawValue: $0.rawValue) })
    }
}

// MARK: - DynamicRequest + Alamofire + Parameters
extension DynamicRequest {
    
    struct Wrapper: Encodable {
        
        let parameters: Parameters
        
        init?(_ parameters: Parameters?) {
            guard let parameters = parameters else { return nil }
            self.parameters = parameters
        }
        
        public func encode(to encoder: Encoder) throws {
            try parameters.encode(to: encoder)
        }
    }
    
    var afParameters: Wrapper? {
        switch encoding {
        case .URL, .JSON:
            return Wrapper(parameters)
        case .multipart:
            return nil
        }
    }
}

// MARK: - DynamicRequest + Alamofire + Multipart
extension DynamicRequest {
    
    func encode(into data: MultipartFormData) {
        guard let parameters = parameters as? MultipartParameters  else { return }
        if let adapter = interceptors.multipartAdapter() {
            encode(parameters, into: data, with: adapter)
        } else {
            encode(parameters, into: data)
        }
    }
    
    private func encode(_ parameters: MultipartParameters, into data: MultipartFormData) {
        parameters.forEach {
            switch $0 {
            case let parameter as DataMultipartParameter:
                data.append(parameter.data, withName: parameter.name)
            #if canImport(UIKit)
            case let parameter as ImageMultipartParameter:
                data.append(parameter.data,
                            withName: parameter.name,
                            fileName: parameter.fileName,
                            mimeType: parameter.mime)
            #endif
            case let parameter as StreamMultipartParameter:
                data.append(parameter.url, withName: parameter.name)
            default:
                preconditionFailure("Not supported MultipartParameters type")
            }
        }
    }
    
    private func encode(_ parameters: MultipartParameters, into data: MultipartFormData, with adapter: IORequestMultipartAdapter) {
        parameters.forEach {
            switch $0 {
            case let parameter as DataMultipartParameter:
                data.append(adapter.adapt(parameter.data), withName: parameter.name)
            #if canImport(UIKit)
            case let parameter as ImageMultipartParameter:
                data.append(adapter.adapt(parameter.data),
                            withName: parameter.name,
                            fileName: parameter.fileName,
                            mimeType: parameter.mime)
            #endif
            case let parameter as StreamMultipartParameter:
                data.append(adapter.adapt(parameter.url), withName: parameter.name)
            default:
                preconditionFailure("Not supported MultipartParameters type")
            }
        }
    }
}

// MARK: - EncodingConfiguration + URLEncodedFormParameterEncoder
extension Http.EncodingConfiguration {
    
    /// `URLEncodedFormParameterEncoder`
    public var URLEncoded: URLEncodedFormParameterEncoder {

        let arrayEncoding: URLEncodedFormEncoder.ArrayEncoding
        switch array {
        case .brackets:
            arrayEncoding = .brackets
        case .noBrackets:
            arrayEncoding = .noBrackets
        }
        
        let boolEncoding: URLEncodedFormEncoder.BoolEncoding
        switch bool {
        case .literal:
            boolEncoding = .literal
        case .numeric:
            boolEncoding = .numeric
        }
        
        let dataEncoding: URLEncodedFormEncoder.DataEncoding
        switch data {
        case .base64:
            dataEncoding = .base64
        case .deferredToData:
            dataEncoding = .deferredToData
        case let .custom(action):
            dataEncoding = .custom(action)
        }
        
        let dateEncoding: URLEncodedFormEncoder.DateEncoding
        switch date {
        case .iso8601:
            dateEncoding = .iso8601
        case .deferredToDate:
            dateEncoding = .deferredToDate
        case .secondsSince1970:
            dateEncoding = .secondsSince1970
        case .millisecondsSince1970:
            dateEncoding = .millisecondsSince1970
        case let .formatted(formatter):
            dateEncoding = .formatted(formatter)
        case let .custom(action):
            dateEncoding = .custom(action)
        }
        
        return .init(encoder: .init(arrayEncoding: arrayEncoding,
                                    boolEncoding: boolEncoding,
                                    dataEncoding: dataEncoding,
                                    dateEncoding: dateEncoding))
    }
}

// MARK: - Array + IOInterceptor
private extension Array where Element == any IOInterceptor {
    
    func multipartAdapter() -> IORequestMultipartAdapter? {
        compactMap { $0 as? IORequestMultipartAdapter }.first
    }
}
