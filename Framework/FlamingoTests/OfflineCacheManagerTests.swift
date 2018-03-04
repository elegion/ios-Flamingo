//
//  OfflineCacheManagerTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import XCTest
import Flamingo

class OfflineCacheManagerTests: XCTestCase {

    var networkClient: NetworkDefaultClient!

    override func setUp() {
        super.setUp()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/")

        networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
    }

    override func tearDown() {
        networkClient = nil
        super.tearDown()
    }

    func test_cachedResponse() {

        let asyncExpectation = expectation(description: #function)
        let request = UsersRequest()

        let urlCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 5 * 1024 * 1024, diskPath: nil)
        urlCache.removeAllCachedResponses()
        let cacheManager = OfflineCacheManager(cache: urlCache,
                                               storagePolicy: .allowed,
                                               networkClient: networkClient)
        networkClient.addOfflineCacheManager(cacheManager)

        let originalTask = networkClient.sendRequest(request) {
            [weak self] (result, _) in

            let task = self?.networkClient.sendRequest(request, completionHandler: {
                (result, _) in

                switch result {
                case .success(let users):
                    XCTAssert(!users.isEmpty, "Users array is empty")
                case .error(let error):
                    XCTFail("User not recieved, error: \(error)")
                }

                asyncExpectation.fulfill()
            })
            XCTAssertNil(task)
        }
        XCTAssertNotNil(originalTask)

        waitForExpectations(timeout: 10) {
            (_) in

        }
    }
}
