//
//  AF+DynamicRequest.swift
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
import Alamofire

/// `ResponseSerializer`, который декодирует данные ответа как универсальное значение, используя любой тип, который соответствует
/// считается ошибкой. Однако, если запрос имеет `HTTPMethod` или ответ имеет действительный код состояния HTTP
/// для пустых ответов будет возвращено пустое значение. Если декодированный тип соответствует `Empty`,
/// будет возвращен тип `empty()`. Если декодированный тип «Пустой», возвращается экземпляр «.value». Если
/// декодированный тип *не* соответствует `Empty` и не является `Empty`, будет выдана ошибка.
public final class IOResponseSerializer<Response>: ResponseSerializer where Response: CRest.Response {
    
    public typealias SerializedObject = Response
    
    public let decoder: JSONDecoder
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>
    public let dataPreprocessor: DataPreprocessor
    
    public init(_ request: DynamicRequest, _ dataPreprocessor: DataPreprocessor = IOResponseSerializer.defaultDataPreprocessor) {
        self.decoder = request.decoder
        self.dataPreprocessor = dataPreprocessor
        self.emptyResponseCodes = request.emptyResponseCodes
        self.emptyRequestMethods = request.afEmptyRequestMethods
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Response {
        if let error {
            throw error
        } else if let empty = CRest.Empty() as? Response {
            guard
                emptyResponseAllowed(forRequest: request, response: response)
            else { throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength) }
            return empty
        } else if var data, !data.isEmpty {
            data = try dataPreprocessor.preprocess(data)
            return try decoder.decode(Response.self, from: data)
        } else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
    }
}
