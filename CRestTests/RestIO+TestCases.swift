//
//  RestIO+TestCases.swift
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

import CRest
import Foundation
import CFoundation
import protocol Alamofire.EmptyResponse

struct RestConfiguration: RestIOConfiguration {
    
    let allHostsMustBeEvaluated: Bool = false
    let informant = NetworkInformant(logger: .init(level: .debug))
}

extension EndPoint {
 
    static let restEndPoint = EndPoint(rawValue: "https://nonexistent-domain.org")
}

extension Request {
    
    static let echo: Self = .init(endPoint: .restEndPoint, path: "v1/echo")
    static let crypto: Self = .init(endPoint: .restEndPoint, path: "/v1/crypto")
    static let upload: Self = .init(endPoint: .restEndPoint, path: "/v1/upload")
    static let download: Self = .init(endPoint: .restEndPoint, path: "/v1/download")
}

extension Http {
    
    static let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
}

extension Http.Headers {
    
    enum Keys: String, HeaderKeys {

        case accept = "Accept"
        case authorization = "Authorization"
        case acceptLanguage = "Accept-Language"
        case appVersion = "Application-Version"
        case appPlatform = "Application-Platform"
    }
    
    static var `default`: Http.Headers.Builder<Keys> {
        Http.Headers.Builder(keyedBy: Keys.self)
            .with(value: "1.0", for: .appVersion)
            .with(value: "iOS", for: .appPlatform)
            .with(value: "ru", for: .acceptLanguage)
            .with(value: "application/json", for: .accept)
            .with(value: "Bearer \(Http.token)", for: .authorization)
    }
}

extension CRest.Http.EncodingConfiguration {

    public static var restUrlEncoder: Self { .init(date: .iso8601) }
}

// MARK: - JSONDecoder + Default
extension JSONDecoder {
    
    static var `default`: JSONDecoder { .init() }
}

// MARK: - JSONEncoder + Default
extension JSONEncoder {
 
    /// Кодирование все ответы сервера
    static var `default`: JSONEncoder { .init() }
}


extension DynamicRequest.Builder {
    
    static var `default`: Self {
        .init()
        .with(headers: Http.Headers.default)
        .with(decoder: .default)
        .with(encoder: .default)
        .with(emptyResponseCodes: [200, 204])
        .with(emptyRequestMethods: Set(Http.Method.allCases))
    }
}

extension CRest.Empty: EmptyResponse {
    
    static var value: Self {
        .init()
    }
    
    public static func emptyValue() -> CRest.Empty {
        .value
    }
}

struct RestError: ServerError, Response {
    
    let code: Int
    let message: String
}

extension AsyncRestIO {
    
    private func send<Response, Parameters>(for request: Request,
                                            parameters: Parameters?,
                                            response: Response.Type,
                                            method: Http.Method,
                                            encoding: Http.Encoding) async throws -> Response where Response: CRest.Response, Parameters: CRest.Parameters {
        let dynamicRequest = try DynamicRequest
            .Builder
            .default
            .with(url: request.rawValue)
            .with(method: method)
            .with(encoding: encoding)
            .with(parameters: parameters)
            .build()
        do {
            return try await perform(dynamicRequest, response: Response.self)
        } catch let NetworkError.http(code, data) {
            guard let data = data else { throw NetworkError.http(code, data: data) }
            do {
                throw try dynamicRequest.decoder.decode(RestError.self, from: data)
            } catch let error as RestError {
                throw NetworkError.server(error)
            } catch {
                throw NetworkError.http(code, data: data)
            }
        } catch {
            throw error
        }
    }
}

