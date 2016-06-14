//
//  NetworkCache.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Cache

public protocol NetworkCacheManager: class {

    func cacheKeyFromRequest(request: NSURLRequest) -> String
    func responseDataForRequest(request: NSURLRequest) -> NSData?
    func setResponseData(responseData: NSData, forRequest request: NSURLRequest)
    func clearDataForRequest(request: NSURLRequest)
    func clearCache()
}

public final class NetworkDefaultCacheManager: NetworkCacheManager {
    
    private let syncCache: SyncHybridCache
    
    public required init(cacheName: String) {
        let cache = HybridCache(name: cacheName)
        
        syncCache = SyncHybridCache(cache)
    }
    
    public func cacheKeyFromRequest(request: NSURLRequest) -> String {
        return (request.HTTPMethod! + request.URL!.absoluteString).md5()
    }
    
    public func responseDataForRequest(request: NSURLRequest) -> NSData? {
        return syncCache.object(cacheKeyFromRequest(request))
    }
    
    public func setResponseData(responseData: NSData, forRequest request: NSURLRequest) {
        syncCache.add(cacheKeyFromRequest(request), object: responseData)
    }
    
    public func clearDataForRequest(request: NSURLRequest) {
        syncCache.remove(cacheKeyFromRequest(request))
    }
    
    public func clearCache() {
        syncCache.clear()
    }
}
