//
//  Base64+JSON.swift
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

/// Объект, который декодирует экземпляры типа Base64 данных из объектов JSON.
public protocol Base64JSONDecoder {
    
    /// Декодер
    static var decoder: JSONDecoder {  get }
}

// MARK: - Base64JSONDecoder + Default
public extension Base64JSONDecoder {
    
    static var decoder: JSONDecoder {  .init() }
}

/// Объект, который кодирует экземпляры типа Base64 данных как объекты JSON.
public protocol Base64JSONEncoder {
    
    /// Инкодер
    static var encoder: JSONEncoder {  get }
}

// MARK: - Base64JSONEncoder + Default
public extension Base64JSONEncoder {
    
    static var encoder: JSONEncoder {  .init() }
}
