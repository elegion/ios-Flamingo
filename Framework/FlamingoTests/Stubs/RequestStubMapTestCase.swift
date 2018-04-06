//
// Created by Dmitrii Istratov on 05-04-2018.
// Copyright (c) 2018 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class RequestStubMapTestCase: XCTestCase {
    // swiftlint:disable force_unwrapping
    // disabled because we know what this url string is valid
    private let url = URL(string: "https://e-legion.com")!
    // swiftlint:enable force_unwrapping

    private let method: HTTPMethod = .get
    private let params: [String: Int] = ["a": 1]

    private var responseStub: ResponseStub {
        return ResponseStub(
            statusCode: .ok,
            headers: [:],
            body: nil,
            error: nil
        )
    }

    private var requestStub: RequestStub {
        return RequestStub(
            url: self.url,
            method: self.method,
            params: self.params
        )
    }

    public func test_creation() {
        let expectedUrl = url
        let expectedMethod = method
        let expectedParams = params

        let map = RequestStubMap(request: requestStub, responseStub: responseStub)

        XCTAssertEqual(expectedUrl, map.url)
        XCTAssertEqual(expectedMethod, map.method)
        XCTAssertNotNil(map.params)

        guard let params = map.params as? [String: Int] else {
            XCTFail("Params type must be as type of expected params!")
            return
        }
        XCTAssertEqual(expectedParams, params)
        XCTAssertEqual(responseStub.statusCode, map.responseStub.statusCode)
        XCTAssertEqual(responseStub.headers, map.responseStub.headers)
        XCTAssertNil(map.responseStub.error)
        XCTAssertNil(map.responseStub.body)
    }
}
