//
//  OfflineCacheManager.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

open class OfflineCacheManager: NetworkClientReporter, NetworkClientMutater {
    let cache: URLCache
    let storagePolicy: URLCache.StoragePolicy
    unowned let networkClient: NetworkDefaultClient

    init(cache: URLCache, storagePolicy: URLCache.StoragePolicy, networkClient: NetworkDefaultClient) {
        self.cache = cache
        self.storagePolicy = storagePolicy
        self.networkClient = networkClient
    }

    public func willSendRequest<Request>(_ networkRequest: Request) where Request : NetworkRequest {

    }

    public func didRecieveResponse<Request>(for request: Request, context: NetworkContext) where Request : NetworkRequest {
        do {
            if let response = context.response,
                let data = context.data {
                let urlRequest = try networkClient.urlRequest(from: request)
                let cached = CachedURLResponse(response: response,
                                               data: data,
                                               userInfo: nil,
                                               storagePolicy: storagePolicy)

                cache.storeCachedResponse(cached, for: urlRequest)
            }
        } catch {

        }
    }

    public func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request : NetworkRequest {
        do {
            let urlRequest = try networkClient.urlRequest(from: request)
            if let cached = cache.cachedResponse(for: urlRequest) {
                return (cached.data, cached.response, nil)
            }
        } catch {

        }
        return nil
    }
}
