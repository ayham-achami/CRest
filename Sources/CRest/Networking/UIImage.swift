//
//  UIImage.swift
//

#if canImport(UIKit)
import UIKit

// MARK: - UIImage + Serialization
public extension UIImage {

    /// Типы серлизуемых изображений
    ///
    /// - PNG: PNG формат
    /// - JPEG: JPEG формат
    enum Serialization: String {
        
        case png
        case jpeg
    }

    /// Cерлизация в байты
    /// - Parameters:
    ///   - serialization: формат серлизация
    ///   - compressionQuality: Качество сжатия
    func serialized(_ serialization: Serialization, compressionQuality: CGFloat = 1.0) throws -> Data {
        let data: Data?
        switch serialization {
        case .png:
            data = pngData()
        case .jpeg:
            data = jpegData(compressionQuality: compressionQuality)
        }
        guard let data else { throw SerializationError(UIImage.self) }
        return data
    }
}
#endif
