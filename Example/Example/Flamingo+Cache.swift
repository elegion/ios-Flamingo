//
//  Flamingo+Cache.swift
//  Flamingo
//
//  Created by Ildar Gilfanov on 25/07/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation
import Cache
import Flamingo

public final class NetworkDefaultOfflineCacheManager: NetworkOfflineCacheManager {
    
    private let syncCache: SyncHybridCache
    
    public required init(cacheName: String) {
        let cache = HybridCache(name: cacheName)
        
        syncCache = SyncHybridCache(cache)
    }
    
    public func cacheKeyFromRequest(_ request: URLRequest) -> String {
        return (request.httpMethod! + request.url!.absoluteString).md5()
    }
    
    public func responseDataForRequest(_ request: URLRequest) -> Data? {
        return syncCache.object(cacheKeyFromRequest(request))
    }
    
    public func setResponseData(_ responseData: Data, forRequest request: URLRequest) {
        syncCache.add(cacheKeyFromRequest(request), object: responseData)
    }
    
    public func clearDataForRequest(_ request: URLRequest) {
        syncCache.remove(cacheKeyFromRequest(request))
    }
    
    public func clearCache() {
        syncCache.clear()
    }
}
