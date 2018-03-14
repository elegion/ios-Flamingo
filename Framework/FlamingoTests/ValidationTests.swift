//
//  FlamingoTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 25.09.17.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

class RealFailedTestRequest: NetworkRequest {

    var URL: URLConvertible {
        return "v2/59c956433f0000910183f797"
    }

    var method: HTTPMethod {
        return .put
    }

    var parameters: [String: Any]? {
        return ["some_param": 12]
    }

    var parametersEncoder: ParametersEncoder {
        return JSONParametersEncoder()
    }

    typealias ResponseSerializer = StringResponseSerializer

    var responseSerializer: ResponseSerializer {
        return ResponseSerializer()
    }
}

class ValidationTests: XCTestCase {

    var client: NetworkClient!

    override func setUp() {
        super.setUp()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/")
        client = NetworkDefaultClient(configuration: configuration, session: .shared)
    }

    override func tearDown() {
        client = nil
        super.tearDown()
    }

    func testResponseStatusCode() {

        let asyncExpectation = expectation(description: "Async")

        let request = RealFailedTestRequest()
        client.sendRequest(request) {
            result, context in

            switch result {
            case .success:
                XCTFail("Should be error")
            case .error(let error):
                if let statusCode = context?.response?.statusCode {
                    XCTAssertEqual(statusCode, 301, "Not correct status code")
                } else {
                    XCTFail("Should be another error, \(error)")
                }
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (_) in }
    }
}
