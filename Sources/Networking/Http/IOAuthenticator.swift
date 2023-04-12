//
//  IOAuthenticator.swift
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

import Foundation

/// Протокол контроля статус авторизации
public protocol IOAuthenticator: AnyObject, IOInterceptor {
    
    /// Запрос обновления
    var refreshRequest: Request { get }
    
    /// Кода ошибок требующие повторной авторизации
    var refreshStatusCodes: [Int] { get }
}

/// Авторизации по BearerToken
public protocol BearerCredential {
    
    /// Токен
    var access: String { get }
    
    /// Валидный ли токен 
    var isValidated: Bool { get }
}

/// Учетные данные аутентификации
public protocol BearerCredentialProvider {
    
    /// Учетные данные аутентификации
    var credential: BearerCredential { get }
    
    @discardableResult
    /// Запрос обновления учетных данных аутентификации
    /// - Returns: `BearerCredential`
    func refresh() async throws -> BearerCredential
}

/// Протокол контроля статус авторизации по BearerToken
public protocol IOBearerAuthenticator: IOAuthenticator {
    
    /// Провайдер авторизации
    var provider: BearerCredentialProvider { get }
}
