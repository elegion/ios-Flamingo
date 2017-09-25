//
//  FlamingoTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 25.09.17.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo
import Foundation

fileprivate struct MockData: Codable {

}

fileprivate class TestRequest: NetworkRequest {

    var URL: URLConvertible {
        return "/5185415ba171ea3a00704eed"
    }

    var method: HTTPMethod {
        return .put
    }

    var parametersEncoder: ParametersEncoder {
        return JSONParametersEncoder()
    }

    typealias ResponseSerializer = CodableJSONSerializer<MockData>

    var responseSerializer: CodableJSONSerializer<MockData> {
        return ResponseSerializer()
    }
}

class ValidationTests: XCTestCase {

    var client: NetworkClient!
    
    override func setUp() {
        super.setUp()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/v2/")
        client = NetworkDefaultClient(configuration: configuration, session: .shared)
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }
    
    func testResponseStatusCode() {

        let asyncExpectation = expectation(description: "Async")

        let request = TestRequest()
        client.sendRequest(request) {
            (result, context) in

            switch result {
            case .success:
                XCTFail("Should be error")
            case .error(let error):
                if let statusCode = context?.response?.statusCode {
                    XCTAssertEqual(statusCode, 404, "Not correct status code")
                } else {
                    XCTFail("Should be another error, \(error)")
                }
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) {
            (_) in

        }
    }
}
