//
//  OfflineCacheManager.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public protocol OfflineCacheProtocol: class {
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest)
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
}

extension URLCache: OfflineCacheProtocol {

}

open class OfflineCacheManager: NetworkClientReporter, NetworkClientMutater {
    public typealias IsOfflineClosure = () -> Bool

    let cache: OfflineCacheProtocol
    let storagePolicy: URLCache.StoragePolicy
    private let reachability: IsOfflineClosure
    unowned let networkClient: NetworkDefaultClient
    private var shouldReplaceResponse: Bool {
        return reachability()
    }

    public init(cache: OfflineCacheProtocol,
                storagePolicy: URLCache.StoragePolicy = .allowed,
                networkClient: NetworkDefaultClient,
                reachability: @escaping IsOfflineClosure) {
        self.cache = cache
        self.storagePolicy = storagePolicy
        self.networkClient = networkClient
        self.reachability = reachability
    }

    open func willSendRequest<Request>(_ networkRequest: Request) where Request : NetworkRequest {

    }

    open func didRecieveResponse<Request>(for request: Request, context: NetworkContext) where Request : NetworkRequest {
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

    open func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request : NetworkRequest {

        do {
            let urlRequest = try networkClient.urlRequest(from: request)
            if shouldReplaceResponse,
                let cached = cache.cachedResponse(for: urlRequest) {
                return (cached.data, cached.response, nil)
            }
        } catch {

        }
        return nil
    }
}

extension NetworkDefaultClient {
    public func addOfflineCacheManager(_ manager: OfflineCacheManager) {
        addReporter(manager)
        addMutater(manager)
    }
}
