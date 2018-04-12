//
//  ResponseStubTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 04-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

typealias TestStub = ResponseStub

class ResponseStubTestCase: XCTestCase {
    private var stub: TestStub {
        return TestStub(body: Data())
    }

    public func test_gettingStatusCode_expectedDefaultCodeOk() {
        let expected = StatusCodes.ok
        let stub = self.stub

        let actual = stub.statusCode

        XCTAssertEqual(expected, actual)
    }

    public func test_gettingHeaders_expectedDefaultHeaders() {
        let expected: [String: String] = [:]
        let stub = self.stub

        let actual = stub.headers

        XCTAssertEqual(expected, actual ?? [:])
    }

    public func test_creatingFromString() {
        let bodyString = ""
        let stub = TestStub(bodyString: bodyString)
        guard let body = stub.body else {
            XCTFail(" ")
            return 
        }

        XCTAssertEqual(body.data, bodyString.data(using: .utf8))
    }

    public func test_creatingWithNilBody() {
        let stub = TestStub(statusCode: .ok, headers: nil, body: nil, error: nil)

        XCTAssertNil(stub.body)
    }
}
