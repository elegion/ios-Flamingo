//
//  GetDataTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 27.09.17.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

class GetDataTests: XCTestCase {
    
    var client: NetworkClient!
    
    override func setUp() {
        super.setUp()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/")
        client = NetworkDefaultClient(configuration: configuration, session: .shared)
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }

    func testGetUsers() {
        let asyncExpectation = expectation(description: "Async")
        let request = UsersRequest(useMock: false)

        client.sendRequest(request) {
            (result, context) in

            switch result {
            case .success(let users):
                XCTAssert(!users.isEmpty, "Users should not be empty")
                if let first = users.first {
                    XCTAssertEqual(first.email, "Sincere@april.biz", "Not correct parsing")
                }
            case .error(let error):
                XCTFail("Should be correct response. Error \(error)")
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) {
            (_) in

        }
    }
}
