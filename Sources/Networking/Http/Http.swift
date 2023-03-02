//
//  Http.swift
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

/// Http нэмспасе
public enum Http {
    
    /// Объект, кодирующий в строки запроса в кодировке URL.
    public struct EncodingConfiguration {
    
        /// Кодировка, используемая для значений `Array`
        public enum ArrayEncoding {
            
            case brackets
            case noBrackets
        }
        
        /// Кодировка, используемая для значений `Bool`
        public enum BoolEncoding {
            
            case numeric
            case literal
        }
        
        /// Кодировка, используемая для значений `Data`
        public enum DataEncoding {
            
            case base64
            case deferredToData
            case custom((Data) throws -> String)
        }
        
        /// Кодировка, используемая для значений `Date`
        public enum DateEncoding {
            
            case iso8601
            case deferredToDate
            case secondsSince1970
            case millisecondsSince1970
            case formatted(DateFormatter)
            case custom((Date) throws -> String)
        }
        
        /// Конфигурация по умолчанию
        public static var `default`: Self { .init() }
        
        /// Кодировка, используемая для значений `Bool`
        public let bool: BoolEncoding
        
        /// Кодировка, используемая для значений `Date`
        public let data: DataEncoding
        
        /// Кодировка, используемая для значений `Date`
        public let date: DateEncoding
        
        /// Кодировка, используемая для значений `Array`
        public let array: ArrayEncoding
        
        /// Инициализация
        /// - Parameters:
        ///   - bool: Кодировка, используемая для значений `Bool`
        ///   - data: Кодировка, используемая для значений `Data`
        ///   - date: Кодировка, используемая для значений `Date`
        ///   - array: Кодировка, используемая для значений `Array`
        public init(bool: BoolEncoding = .numeric,
                    data: DataEncoding = .base64,
                    date: DateEncoding = .deferredToDate,
                    array: ArrayEncoding = .brackets) {
            self.bool = bool
            self.data = data
            self.date = date
            self.array = array
        }
    }
    
    /// Типы енкднга данных
    public enum Encoding {
        
        case JSON
        case multipart
        case URL(EncodingConfiguration)
    }

    /// Определения Http методов
    ///
    /// See https://tools.ietf.org/html/rfc7231#section-4.3
    public enum Method: String, CaseIterable {
        
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
}
