//
//  NetworkCache.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

public protocol NetworkOfflineCacheManager: class {

    func cacheKeyFromRequest(_ request: URLRequest) -> String
    func responseDataForRequest(_ request: URLRequest) -> Data?
    func setResponseData(_ responseData: Data, forRequest request: URLRequest)
    func clearDataForRequest(_ request: URLRequest)
    func clearCache()
}
