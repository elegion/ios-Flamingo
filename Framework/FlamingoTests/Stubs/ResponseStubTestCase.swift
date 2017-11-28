//
//  ResponseStubTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 04-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

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

        XCTAssertEqual(expected, actual)
    }
}
