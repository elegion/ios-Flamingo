//
// Created by Dmitrii Istratov on 05-04-2018.
// Copyright (c) 2018 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

final class RequestStubMapTestCase: XCTestCase {
    
    // swiftlint:disable:next force_unwrapping
    private let url = URL(string: "https://e-legion.com")!

    private let method: HTTPMethod = .get
    private let body: [String: Int] = ["a": 1]

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
            url: url,
            method: method,
            body: body
        )
    }

    public func test_creation() {
        let expectedUrl = url
        let expectedMethod = method
        let expectedBody = body

        let map = RequestStubMap(request: requestStub, responseStub: responseStub)

        XCTAssertEqual(expectedUrl, map.url)
        XCTAssertEqual(expectedMethod, map.method)
        XCTAssertNotNil(map.body)

        guard let body = map.body as? [String: Int] else {
            XCTFail("Params type must be as type of expected params!")
            return
        }
        
        XCTAssertEqual(expectedBody, body)
        XCTAssertEqual(responseStub.statusCode, map.responseStub.statusCode)
        XCTAssertEqual(responseStub.headers, map.responseStub.headers)
        XCTAssertNil(map.responseStub.error)
        XCTAssertNil(map.responseStub.body)
    }
}
