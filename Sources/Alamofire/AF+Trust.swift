//
//  AF+Trust.swift
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

import Alamofire
import Foundation

// MARK: - TrustEvaluatorWrapper

/// Обертка `TrustEvaluator` в `ServerTrustEvaluating`
class TrustEvaluatorWrapper: ServerTrustEvaluating {

    let evaluator: TrustEvaluator

    init(_ evaluator: TrustEvaluator) {
        self.evaluator = evaluator
    }

    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        try evaluator.evaluate(trust, forHost: EndPoint(rawValue: host))
    }
}

// MARK: - RestIOConfiguration + ServerTrustManager
extension RestIOConfiguration {
    
    public var serverTrustManager: ServerTrustManager? {
        guard let trustEvaluating = trustEvaluating else { return nil }
        let applies: [String: ServerTrustEvaluating] = trustEvaluating.reduce([:]) { result, evaluating in
            guard let key = URLComponents(string: evaluating.key.rawValue)?.host else { return [:] }
            var applies = [String: ServerTrustEvaluating]()
            switch evaluating.value {
            case let .custom(evaluator):
                applies[key] = TrustEvaluatorWrapper(evaluator)
            case .default:
                applies[key] = DefaultTrustEvaluator()
            case .disabled:
                applies[key] = DisabledTrustEvaluator()
            case .publicKeys:
                applies[key] = PublicKeysTrustEvaluator()
            case .revocation:
                applies[key] = RevocationTrustEvaluator()
            case .pinnedCertificates:
                applies[key] = PinnedCertificatesTrustEvaluator()
            case let .composite(evaluators):
                applies[key] = CompositeTrustEvaluator(evaluators: evaluators.afEvaluators)
            }
            return applies.merging(result) { (_, new) in new }
        }
        return ServerTrustManager(evaluators: applies)
    }
}

// MARK: - Array + TrustEvaluatingType
extension Array where Element == TrustEvaluatingType {

    var afEvaluators: [ServerTrustEvaluating] {
        map { type in
            switch type {
            case let .custom(evaluator):
                return [TrustEvaluatorWrapper(evaluator)]
            case .default:
                return [DefaultTrustEvaluator()]
            case .disabled:
                return [DisabledTrustEvaluator()]
            case .publicKeys:
                return [PublicKeysTrustEvaluator()]
            case .revocation:
                return [RevocationTrustEvaluator()]
            case .pinnedCertificates:
                return [PinnedCertificatesTrustEvaluator()]
            case let .composite(evaluators):
                return evaluators.afEvaluators
            }
        }.reduce([], +)
    }
}
