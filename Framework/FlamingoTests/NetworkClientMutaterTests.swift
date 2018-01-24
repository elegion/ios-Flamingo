//
//  NetworkClientMutaterTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 24.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import XCTest
import Flamingo

private final class MockMutater: NetworkClientMutater {
    var responseReplaceWasCalled: Bool = false

    func reponse<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request : NetworkRequest {
        responseReplaceWasCalled = true
        return nil
    }
}

class NetworkClientMutaterTests: XCTestCase {

    var networkClient: NetworkClientMutable!
    
    override func setUp() {
        super.setUp()

        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/")
        networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
    }
    
    override func tearDown() {
        networkClient = nil
        super.tearDown()
    }

    func test_mutaterCalls() {
        let mutater1 = MockMutater()
        let mutater2 = MockMutater()

        networkClient.addMutater(mutater1)
        networkClient.addMutater(mutater2)

        let asyncExpectation = expectation(description: "Async")

        networkClient.removeMutater(mutater2)
        let request = TestRequest()
        networkClient.sendRequest(request) { (_, _) in
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (_) in
            XCTAssertTrue(mutater1.responseReplaceWasCalled)
            XCTAssertFalse(mutater2.responseReplaceWasCalled)
        }
    }
}
