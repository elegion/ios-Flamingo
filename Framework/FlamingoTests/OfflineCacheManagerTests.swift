//
//  OfflineCacheManagerTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

private final class MockCache: OfflineCacheProtocol {
    var wasCalledCache = false
    var wasCalledResponse = false

    var storage: [URLRequest: CachedURLResponse] = [:]

    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        storage[request] = cachedResponse
        wasCalledCache = true
    }

    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        let result = storage[request]
        if result != nil {
            wasCalledResponse = true
        }
        return result
    }
}

private final class MockUsers: NetworkClientMutater {
    var wasCalledResponse = false

    func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request: NetworkRequest {
        let dataAsString = """
[
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "address": {
      "street": "Kulas Light",
      "suite": "Apt. 556",
      "city": "Gwenborough",
      "zipcode": "92998-3874",
      "geo": {
        "lat": "-37.3159",
        "lng": "81.1496"
      }
    },
    "phone": "1-770-736-8031 x56442",
    "website": "hildegard.org",
    "company": {
      "name": "Romaguera-Crona",
      "catchPhrase": "Multi-layered client-server neural-net",
      "bs": "harness real-time e-markets"
    }
  }
]
"""

        let response = HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        wasCalledResponse = true
        return (dataAsString.data(using: .utf8), response, nil)
    }
}

class OfflineCacheManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    var networkClient: NetworkDefaultClient {
        let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/",
                                                        parallel: false)

        let client = NetworkDefaultClient(configuration: configuration, session: .shared)
        return client
    }

    func test_cachedResponse() {

        let urlCache = MockCache()
        let request = UsersRequest()
        do {
            let client = networkClient

            let cacheManager = OfflineCacheManager(cache: urlCache,
                                                   storagePolicy: .allowed,
                                                   networkClient: client,
                                                   reachability: { return true })
            client.addOfflineCacheManager(cacheManager)
            let mockUsers = MockUsers()
            client.addMutater(mockUsers)

            client.sendRequest(request) {
                result, _ in

                do {
                    let value = try result.get()
                    XCTAssertEqual(value.count, 1)
                } catch {
                    XCTAssertNil(error, error.localizedDescription)
                }
            }
            XCTAssertTrue(mockUsers.wasCalledResponse)
            XCTAssertTrue(urlCache.wasCalledCache)
            XCTAssertFalse(urlCache.wasCalledResponse)
        }

        do {
            let client = networkClient

            let cacheManager = OfflineCacheManager(cache: urlCache,
                                                   storagePolicy: .allowed,
                                                   networkClient: client,
                                                   reachability: { return true })
            client.addOfflineCacheManager(cacheManager)
            let mockUsers = MockUsers()
            client.addMutater(mockUsers)

            client.sendRequest(request) {
                result, _ in

                do {
                    let value = try result.get()
                    XCTAssertEqual(value.count, 1)
                } catch {
                    XCTAssertNil(error, error.localizedDescription)
                }
            }
            XCTAssertFalse(mockUsers.wasCalledResponse)
            XCTAssertTrue(urlCache.wasCalledResponse)
        }
    }
}
