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
import SwiftHash

public final class NetworkDefaultOfflineCacheManager: NetworkOfflineCacheManager {
    
    private let syncCache: HybridCache
    
    public required init(cacheName: String) {
        syncCache = HybridCache(name: cacheName)
    }
    
    public func cacheKeyFromRequest(_ request: URLRequest) -> String {
        return MD5(request.httpMethod! + request.url!.absoluteString)
    }
    
    public func responseDataForRequest(_ request: URLRequest) -> Data? {
        return syncCache.object(forKey: cacheKeyFromRequest(request))
    }
    
    public func setResponseData(_ responseData: Data, forRequest request: URLRequest) throws {
        try syncCache.addObject(responseData, forKey: cacheKeyFromRequest(request))
    }
    
    public func clearDataForRequest(_ request: URLRequest) throws {
        try syncCache.removeObject(forKey: cacheKeyFromRequest(request))
    }
    
    public func clearCache() throws {
        try syncCache.clear()
    }
}
