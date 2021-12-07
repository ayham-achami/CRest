//
//  TrustEvaluating.swift
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

/// Протокол реализующий логику оценки доверии
public protocol TrustEvaluator {

    /// Оценивает `SecTrust` для данного `EndPoint`.
    /// - Parameters:
    ///   - trust: Значение `SecTrust` для оценки.
    ///   - host: EndPoint, для которого нужно оценить значение` SecTrust`.
    func evaluate(_ trust: SecTrust, forHost host: EndPoint) throws
}

/// Типы оценки доверии.
/// Приложениям рекомендуется всегда проверять хост в производственных средах, чтобы
/// гарантировать действительность цепочки сертификатов сервера.
public enum TrustEvaluatingType {

    /// Оценщик, который использует оценку доверия сервера по умолчанию,
    /// позволяя вам контролировать, проверять ли хост, предоставленный запросом.
    case `default`
    /// Отключает все оценки, которые, в свою очередь, всегда будут считать любое доверие сервера допустимым.
    /// ** ЭТО ОЦЕНИТЕЛЬ НЕ ДОЛЖЕН ИСПОЛЬЗОВАТЬСЯ В ПРОДАКЕШН! **
    case disabled
    /// Оценщик, который использует доверие по умолчанию и отозвал доверие к серверу.
    /// оценки, позволяющие вам контролировать, проверять ли хост, предоставленный запросом,
    /// а также указывать флаги отзыва для тестирования отозванных сертификатов.
    /// Платформа iOS не запускали тестирование на отозванные сертификаты автоматически до iOS 10.1
    case revocation
    /// Использует закрепленные открытые ключи для проверки доверия сервера.
    /// Доверие к серверу считается действительным, если один из закрепленных открытых
    /// ключей совпадает с одним из открытых ключей сертификата сервера.
    /// При проверке цепочки сертификатов и хоста закрепление открытого ключа обеспечивает
    /// очень безопасную форму проверки доверия сервера, смягчая большинство, если не все, атаки MITM
    case publicKeys
    /// Использует закрепленные сертификаты для проверки доверия сервера.
    /// Доверие к серверу считается действительным, если один из закрепленных сертификатов
    /// соответствует одному из сертификатов сервера.
    /// Благодаря проверке как цепочки сертификатов, так и хоста, закрепление сертификатов
    /// обеспечивает очень безопасную форму проверки доверия сервера, смягчая
    /// большинство, если не все, атаки MITM.
    case pinnedCertificates
    /// Оценщик, который реализует кастомной логики доверии сервера
    case custom(TrustEvaluator)
    /// Использует предоставленные оценщики для проверки доверия сервера.
    /// Доверие считается действительным, только если все оценщики считают это действительным.
    case composite([TrustEvaluatingType])
}

/// Оценка доверии определенному хосту (EndPoint)
public typealias TrustEvaluating = [EndPoint: TrustEvaluatingType]
