//
//  IOResponseSerializer.swift
//  CRest
//
//  Created by Ayham Hylam on 02.03.2023.
//

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
