//
//  AF+Trust.swift
//

import Alamofire
import Foundation

/// Обертка `TrustEvaluator` в `ServerTrustEvaluating`
class TrustEvaluatorWrapper: ServerTrustEvaluating {
    
    /// Логика оценки доверии
    let evaluator: TrustEvaluator
    
    /// Инициализация
    /// - Parameter evaluator: Логика оценки доверии
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
        return ServerTrustManager(allHostsMustBeEvaluated: allHostsMustBeEvaluated, evaluators: applies)
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
