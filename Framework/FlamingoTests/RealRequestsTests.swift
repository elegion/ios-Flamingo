//
//  RealRequestsTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 24.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import XCTest
import Flamingo

struct GeoLocation: Codable {
    var lat: String
    var lng: String
}

struct Address: Codable {
    var street: String
    var suite: String
    var city: String
    var geo: GeoLocation
}

struct Company: Codable {
    var name: String
    var catchPhrase: String
    var bs: String
}

struct User: Codable {
    var id: Int
    var name: String
    var username: String
    var email: String
    var address: Address
    var phone: String
    var website: String
    var company: Company
}

struct UsersRequest: NetworkRequest {

    init() {

    }

    // MARK: - Implementation

    var URL: URLConvertible {
        return "users"
    }

    var useCache: Bool {
        return true
    }

    var responseSerializer: CodableJSONSerializer<[User]> {
        return CodableJSONSerializer<[User]>()
    }
}

class RealRequestsTests: XCTestCase {

    var networkClient: NetworkClient!

    override func setUp() {
        super.setUp()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/")

        networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
    }

    override func tearDown() {
        networkClient = nil
        super.tearDown()
    }

    func test_correctJSONRequest() {
        let asyncExpectation = expectation(description: #function)
        let request = UsersRequest()

        networkClient.sendRequest(request) {
            (result, _) in

            switch result {
            case .success(let users):
                XCTAssert(!users.isEmpty, "Users array is empty")
            case .error(let error):
                XCTFail("User not recieved, error: \(error)")
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) {
            (_) in

        }
    }
}
