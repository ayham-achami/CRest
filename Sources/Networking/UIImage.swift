//
//  UIImage.swift
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

#if canImport(UIKit)
import UIKit

// MARK: - UIImage + Serialization
public extension UIImage {

    /// Типы серилизуемых изображений
    ///
    /// - PNG: PNG формат
    /// - JPEG: JPEG формат
    enum Serialization: String {
        case png
        case jpeg
    }

    /// Серлизация в байты
    /// - Parameters:
    ///   - serialization: фотмат серлизация
    ///   - compressionQuality: Качество сжатия
    func serialized(_ serialization: Serialization, compressionQuality: CGFloat = 1.0) throws -> Data {
        let imageData: Data?
        switch serialization {
        case .png:
            imageData = pngData()
        case .jpeg:
            imageData = jpegData(compressionQuality: compressionQuality)
        }
        guard let data = imageData else { throw SerializationError(UIImage.self) }
        return data
    }
}
#endif
