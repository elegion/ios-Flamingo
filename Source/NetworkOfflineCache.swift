//
//  NetworkCache.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Cache

public protocol NetworkOfflineCacheManager: class {

    func cacheKeyFromRequest(_ request: URLRequest) -> String
    func responseDataForRequest(_ request: URLRequest) -> Data?
    func setResponseData(_ responseData: Data, forRequest request: URLRequest)
    func clearDataForRequest(_ request: URLRequest)
    func clearCache()
}

public final class NetworkDefaultOfflineCacheManager: NetworkOfflineCacheManager {
    
    fileprivate let syncCache: SyncHybridCache
    
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
