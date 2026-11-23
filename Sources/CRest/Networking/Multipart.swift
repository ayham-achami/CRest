//
//  Multipart.swift
//

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif

/// Любой параметр multipart
public protocol MultipartParameter: Sendable {}

/// Мультипартпараметр содержащий любые данные
@frozen public struct DataMultipartParameter: MultipartParameter {

    /// Данные для отправки
    public let data: Data
    /// Ключи данных в наборе
    public let name: String

    /// Добавить данные
    /// - Parameters:
    ///   - value: Данные
    ///   - key: Ключ
    public init(_ data: Data, _ name: String) {
        self.data = data
        self.name = name
    }
}

#if canImport(UIKit)
/// Мультипарт параметр содержащий картинку
@frozen public struct ImageMultipartParameter: MultipartParameter {

    public let data: Data
    public let name: String
    public let fileName: String?
    public let mime: String

    public init(_ image: UIImage,
                _ name: String,
                _ fileName: String? = nil,
                _ serialization: UIImage.Serialization = .png) throws {
        self.data = try image.serialized(serialization)
        self.name = name
        self.fileName = fileName
        self.mime = "image/\(serialization.rawValue)"
    }
    
    public init(_ data: Data,
                _ name: String,
                _ fileName: String?,
                _ mime: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mime = mime
    }
}
#endif

/// Стримить данные в Multipart
@frozen public struct StreamMultipartParameter: MultipartParameter {

    public let url: URL
    public let name: String

    public init(_ url: URL, _ name: String) {
        self.url = url
        self.name = name
    }
}

/// Файловая multipart-часть, для которой адаптер должен подготовить поток по записям.
/// Если поток не подготовлен, запрос отклоняется до отправки.
public struct ChunkedStreamMultipartParameter: MultipartParameter {
    
    /// Ошибка подготовки потока multipart-части.
    public enum StreamError: Error {
        
        /// Адаптер не предоставил поток для кодирования multipart.
        case streamNotFound
    }
    
    /// Локальный файл, который адаптер использует как источник данных.
    public let url: URL
    /// Имя поля multipart.
    public let name: String
    /// Размер исходных данных записи в байтах; допустимые значения определяет адаптер.
    public let chunkSize: UInt64

    var bodyStream: BodyStream?
    
    /// Имя файла в multipart-части.
    public var fileName: String {
        url.lastPathComponent
    }
    
    /// MIME-тип по расширению файла либо `application/octet-stream`.
    public var mimeType: String {
        mimeType(forPathExtension: url.pathExtension)
    }
    
    /// Создаёт параметр без открытия файла и подготовки потока.
    /// - Parameters:
    ///   - url: Локальный файл, доступный до завершения кодирования multipart.
    ///   - name: Имя поля multipart.
    ///   - chunkSize: Размер исходных данных записи в байтах.
    public init(url: URL,
                name: String,
                chunkSize: UInt64 = 65_536) {
        self.url = url
        self.name = name
        self.chunkSize = chunkSize
    }
    
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        } else {
            if
                let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
                let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
                return contentType as String
            }
            
            return "application/octet-stream"
        }
    }
}

/// Параметры в мульти типовых
@frozen public struct MultipartParameters: Parameters {

    private var content: [MultipartParameter] = []
    
    /// Инициализация
    public init() {}

    /// Добавить параметр
    /// - Parameter parameter: Параметр
    public mutating func append(_ parameter: MultipartParameter) {
        content.append(parameter)
    }
    
    /// Преобразует параметры в новый тип
    /// - Parameter transform: Замыкание преобразования
    /// - Returns: Новый тип
    func touch<Result>(_ transform: (MultipartParameters) throws -> Result) rethrows -> Result {
        try transform(self)
    }
    
    /// Stub methods don't use
    /// - Parameter encoder: _
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("MultipartParameters couldn't to be encoding")
    }
}

// MARK: - MultipartParameters + Collection
extension MultipartParameters: Collection {
    
    public var startIndex: [MultipartParameter].Index {
        content.startIndex
    }
    
    public var endIndex: [MultipartParameter].Index {
        content.endIndex
    }
    
    public subscript(index: [MultipartParameter].Index) -> MultipartParameter {
        content[index]
    }
    
    public func index(after index: [MultipartParameter].Index) -> Int {
        content.index(after: index)
    }
}

// MARK: - MultipartParameters + ExpressibleByArrayLiteral
extension MultipartParameters: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: MultipartParameter...) {
        content = .init(elements)
    }
}

// MARK: - MultipartParameters + CustomDebugStringConvertible
extension MultipartParameters: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        content.debugDescription
    }
}

// MARK: - MultipartParameters + CustomStringConvertible
extension MultipartParameters: CustomStringConvertible {
    
    public var description: String {
        content.description
    }
}

// MARK: - IORequestMultipartAdapter + Concurrency
extension IORequestMultipartAdapter {
    
    /// Адаптация часть тела запроса
    /// - Parameter parameter: Любой параметр multipart
    /// - Returns: Любой параметр multipart
    func adapt(_ parameter: MultipartParameter) async throws -> MultipartParameter {
        try await withCheckedThrowingContinuation { continuation in
            switch parameter {
            case let parameter as DataMultipartParameter:
                adapt(parameter, with: continuation)
            #if canImport(UIKit)
            case let parameter as ImageMultipartParameter:
                adapt(parameter, with: continuation)
            #endif
            case let parameter as StreamMultipartParameter:
                adapt(parameter, with: continuation)
            case let parameter as ChunkedStreamMultipartParameter:
                adapt(parameter, with: continuation)
            default:
                preconditionFailure("Not supported MultipartParameters type")
            }
        }
    }
}

// MARK: - IORequestMultipartAdapter + Private
private extension IORequestMultipartAdapter {
    
    func adapt(_ parameter: DataMultipartParameter, with continuation: CheckedContinuation<MultipartParameter, Error>) {
        adapt(parameter.data) { result in
            switch result {
            case .success(let data):
                continuation.resume(returning: DataMultipartParameter(data, parameter.name))
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
    
    #if canImport(UIKit)
    func adapt(_ parameter: ImageMultipartParameter, with continuation: CheckedContinuation<MultipartParameter, Error>) {
        adapt(parameter.data) { result in
            switch result {
            case .success(let data):
                continuation.resume(returning: ImageMultipartParameter(data, parameter.name, parameter.fileName, parameter.mime))
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
    #endif
    
    func adapt(_ parameter: StreamMultipartParameter, with continuation: CheckedContinuation<MultipartParameter, Error>) {
        adapt(parameter.url) { result in
            switch result {
            case .success(let url):
                continuation.resume(returning: StreamMultipartParameter(url, parameter.name))
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
    
    func adapt(_ parameter: ChunkedStreamMultipartParameter, with continuation: CheckedContinuation<MultipartParameter, Error>) {
        adapt(parameter.url, chunkSize: parameter.chunkSize) { result in
            var mutable = parameter
            switch result {
            case .success(let stream):
                mutable.bodyStream = stream
                continuation.resume(returning: mutable)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
