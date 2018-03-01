//
//  StubClientTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class StubClientTestCase: XCTestCase {
    private var client: StubDefaultSession {
        return StubDefaultSession()
    }

    private var url: String {
        return "method"
    }

    private var stub: ResponseStub {
        return ResponseStub(body: Data())
    }

    public func test_creation_expectedClient() {
        let actual = self.client

        XCTAssertNotNil(actual)
    }

    public func test_addingOneStub() {
        let client = self.client

        _ = client.add(self.url, method: HTTPMethod.get, stub: self.stub)
    }

    public func test_addingManyStubs() {
        let client = self.client

        let stubItem = Stub(url: self.url, method: HTTPMethod.get, stub: self.stub)
        let secondStubItem = Stub(url: self.url, method: HTTPMethod.post, stub: self.stub)
        let stubs = [stubItem]
        let secondStubs = [secondStubItem]

        _ = client
            .add(stubs: stubs)
            .add(stubs: secondStubs)
    }

    public func test_detectExistingMockOnUnconfiguredClient_expectedFalse() {
        let client = self.client

        let actual = client.hasStub("some_url/", method: HTTPMethod.get)

        XCTAssertFalse(actual)
    }

    public func test_detectExistingMockOnConfiguredClient_expectedTrue() {
        let url = "some_url/"
        let method = HTTPMethod.get

        let client = self.client
        _ = client.add(url, method: method, stub: self.stub)

        let actual = client.hasStub(url, method: method)

        XCTAssertTrue(actual)
    }

    public func test_detectExistingRegexMockOnClient_expectedTrue() {
        let url = "some_url/"
        let regex = "s.*url"
        let method = HTTPMethod.get

        let client = self.client
        _ = client.add(regex, method: method, stub: self.stub)

        let actual = client.hasStub(url, method: method)

        XCTAssertTrue(actual)
    }

    public func test_detectExistingMockOnClientCheckType_expectedFalse() {
        let url = "some_url/"
        let regex = "s.*url"
        let method = HTTPMethod.get
        let checkedMethod = HTTPMethod.post

        let client = self.client
        _ = client.add(regex, method: method, stub: self.stub)

        let actual = client.hasStub(url, method: checkedMethod)

        XCTAssertFalse(actual)
    }

    public func test_detectExcistingMockOnClientCheckType_expectedTrue() {
        let url = "some_url/"
        let regex = "s.*url"
        let method = HTTPMethod.get
        let checkedMethod = method

        let client = self.client
        _ = client.add(regex, method: method, stub: self.stub)

        let actual = client.hasStub(url, method: checkedMethod)

        XCTAssertTrue(actual)
    }

    public func test_removingStubByMethod_expectedFalse() {
        let url = "some_url/"
        let method = HTTPMethod.get

        let client = self.client
        _ = client.add(self.url, method: method, stub: self.stub)
            .remove(self.url, method: method)

        let actual = client.hasStub(url, method: method)

        XCTAssertFalse(actual)
    }

    public func test_detectingExcistingStubByRequest_expectedTrue() {
        let regex = "s.*url"
        let url = URL(string: "some_url/") ?? URL(fileURLWithPath: "")
        let method = HTTPMethod.get
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let client = self.client
        _ = client.add(regex, method: method, stub: self.stub)

        let actual = client.hasStub(request: request)

        XCTAssertTrue(actual)
    }

    public func test_detectingExcistingStubByRequest_expectedFalse() {
        let url = URL(string: "some_url/") ?? URL(fileURLWithPath: "")
        let regex = "s.*url"
        let method = HTTPMethod.get
        let checkedMethod = HTTPMethod.post
        var request = URLRequest(url: url)
        request.httpMethod = checkedMethod.rawValue

        let client = self.client
        _ = client.add(regex, method: method, stub: self.stub)

        let actual = client.hasStub(request: request)

        XCTAssertFalse(actual)
    }

    public func test_runStubTask_expectedResult() {
        let expectation = self.expectation(description: #function)

        let expectedData = self.stub.body
        let expectedStatusCode = self.stub.statusCode
        let expectedHeaders = self.stub.headers
        let method = HTTPMethod.get

        let client = self.client
            .add(self.url, method: method, stub: self.stub)

        let request = URLRequest(url: URL(string: self.url) ?? URL(fileURLWithPath: ""))

        _ = client.dataTask(with: request) {
            data, response, _ in

            let response = (response as? HTTPURLResponse)

            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedStatusCode, StatusCodes(rawValue: response?.statusCode ?? -1))
            XCTAssertEqual(expectedHeaders, (response?.allHeaderFields as? [String: String]) ?? [:])

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_runStubTaskOnUnconfiguredClient_expectedError() {
        let expectation = self.expectation(description: #function)

        let client = self.client
        if let url = URL(string: self.url) {
            let request = URLRequest(url: url)

            _ = client.dataTask(with: request) {
                _, _, error in

                XCTAssertNotNil(error)

                if let error = error {
                    switch error {
                    case Flamingo.Error.stubClientError(.stubNotFound):
                        break
                    default:
                        XCTFail("Must throws Flamingo.Error.stubClientError(.stubNotFound) error!")
                    }

                    expectation.fulfill()
                }
            }
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }
}
