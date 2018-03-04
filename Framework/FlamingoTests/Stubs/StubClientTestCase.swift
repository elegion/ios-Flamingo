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

    private var url: URL {
        return URL(string: "method") ?? URL(fileURLWithPath: "")
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

        _ = client.add(RequestStub(url: url, method: .get), stub: stub)
    }

    public func test_addingManyStubs() {
        let client = self.client

        let stubItem = RequestStubMap(url: self.url, method: HTTPMethod.get, params: nil, responseStub: self.stub)
        let secondStubItem = RequestStubMap(url: self.url, method: HTTPMethod.post, params: nil, responseStub: self.stub)
        let stubs = [stubItem]
        let secondStubs = [secondStubItem]

        client.add(stubs: stubs)
        client.add(stubs: secondStubs)
    }

    public func test_detectExistingMockOnUnconfiguredClient_expectedFalse() {
        let client = self.client

        let actual = client.hasStub(RequestStub(url: URL(string: "some_url/") ?? URL(fileURLWithPath: ""), method: .get))

        XCTAssertFalse(actual)
    }

    public func test_detectExistingMockOnConfiguredClient_expectedTrue() {
        let url = URL(string: "some_url/") ?? URL(fileURLWithPath: "")
        let method = HTTPMethod.get

        let client = self.client
        let key = RequestStub(url: url, method: method, params: ["key": 1])
        client.add(key, stub: stub)

        XCTAssertTrue(client.hasStub(key))
    }

//    public func test_detectExistingRegexMockOnClient_expectedTrue() {
//        let url = URL(string: "some_url/")!
//        let regex = "s.*url"
//        let method = HTTPMethod.get
//
//        let client = self.client
//        _ = client.add(regex, method: method, stub: self.stub)
//
//        let actual = client.hasStub(url, method: method)
//
//        XCTAssertTrue(actual)
//    }
//
//    public func test_detectExistingMockOnClientCheckType_expectedFalse() {
//        let url = "some_url/"
//        let regex = "s.*url"
//        let method = HTTPMethod.get
//        let checkedMethod = HTTPMethod.post
//
//        let client = self.client
//        _ = client.add(regex, method: method, stub: self.stub)
//
//        let actual = client.hasStub(url, method: checkedMethod)
//
//        XCTAssertFalse(actual)
//    }
//
//    public func test_detectExcistingMockOnClientCheckType_expectedTrue() {
//        let url = "some_url/"
//        let regex = "s.*url"
//        let method = HTTPMethod.get
//        let checkedMethod = method
//
//        let client = self.client
//        _ = client.add(regex, method: method, stub: self.stub)
//
//        let actual = client.hasStub(url, method: checkedMethod)
//
//        XCTAssertTrue(actual)
//    }

    public func test_removingStubByMethod_expectedFalse() {
        let method = HTTPMethod.get

        let key = RequestStub(url: self.url, method: method, params: nil)
        let client = self.client
        client.add(key, stub: self.stub)
        client.remove(key)

        XCTAssertFalse(client.hasStub(key))
    }

//    public func test_detectingExcistingStubByRequest_expectedTrue() {
//        let regex = "s.*url"
//        let url = URL(string: "some_url/") ?? URL(fileURLWithPath: "")
//        let method = HTTPMethod.get
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//
//        let client = self.client
//        _ = client.add(regex, method: method, stub: self.stub)
//
//        let actual = client.hasStub(request: request)
//
//        XCTAssertTrue(actual)
//    }
//
//    public func test_detectingExcistingStubByRequest_expectedFalse() {
//        let url = URL(string: "some_url/") ?? URL(fileURLWithPath: "")
//        let regex = "s.*url"
//        let method = HTTPMethod.get
//        let checkedMethod = HTTPMethod.post
//        var request = URLRequest(url: url)
//        request.httpMethod = checkedMethod.rawValue
//
//        let client = self.client
//        _ = client.add(regex, method: method, stub: self.stub)
//
//        let actual = client.hasStub(request: request)
//
//        XCTAssertFalse(actual)
//    }

    struct MMMRequest: NetworkRequest {

        var URL: URLConvertible {
            return "method"
        }

        var responseSerializer: StringResponseSerializer {
            return StringResponseSerializer()
        }
    }

    func test_convertStubToMutaterRaw() {

        let expectedData = self.stub.body
        let expectedStatusCode = self.stub.statusCode
        let expectedHeaders = self.stub.headers
        let method = HTTPMethod.get
        let expectedError = self.stub.error

        let key = RequestStub(url: self.url, method: method, params: nil)
        let client = self.client
        client.add(key, stub: self.stub)

        let request = MMMRequest()

        let rawTuple = client.response(for: request)
        let response = (rawTuple?.response as? HTTPURLResponse)

        XCTAssertEqual(expectedData, rawTuple?.data)
        XCTAssertEqual(expectedStatusCode, StatusCodes(rawValue: response?.statusCode ?? -1))
        XCTAssertEqual(expectedHeaders, (response?.allHeaderFields as? [String: String]) ?? [:])
        XCTAssertEqual(expectedError?.nsError, rawTuple?.error as NSError?)
    }
}
