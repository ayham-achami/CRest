//
//  Http.swift
//

import Foundation

/// Http
public enum Http {}

// MARK: - Http + Method
extension Http {
    
    /// Определения Http методов
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

// MARK: - Http + Encoding
extension Http {
    
    /// Типы игодинга данных
    public enum Encoding {
        
        case JSON
        case multipart
        case URL(EncodingConfiguration)
    }
}

// MARK: - Http + EncodingConfiguration
extension Http {
    
    /// Объект, кодирующий в строки запроса в URL.
    @frozen public struct EncodingConfiguration {
    
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
}
