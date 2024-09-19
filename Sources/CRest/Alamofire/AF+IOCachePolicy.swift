//
//  AF+IOCachePolicy.swift
//

import Alamofire
import Foundation

/// Объект, который управляет тем, должны ли данные ответа сохраняться в кэше.
struct IOResponseCacher: CachedResponseHandler {
    
    let behavior: IOCacheBehavior
    
    func dataTask(_ task: URLSessionDataTask, willCacheResponse response: CachedURLResponse, completion: @escaping (CachedURLResponse?) -> Void) {
        switch behavior {
        case .never:
            completion(nil)
        case .default:
            completion(response)
        case let .costume(controller):
            completion(controller(task, response))
        }
    }
}

// MARK: - RestIOConfiguration + CachedResponseHandler 
extension RestIOConfiguration {
    
    var cachedResponseHandler: CachedResponseHandler {
        IOResponseCacher(behavior: cacheBehavior)
    }
}
