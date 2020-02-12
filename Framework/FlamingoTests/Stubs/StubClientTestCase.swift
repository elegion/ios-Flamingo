//
//  StubClientTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

final class StubClientTestCase: XCTestCase {
    
    private var client: StubsDefaultManager {
        return StubsDefaultManager()
    }

    private var url: URL {
        return URL(string: "method") ?? URL(fileURLWithPath: "")
    }

    private var stub: ResponseStub {
        return ResponseStub(body: Data())
    }

    func test_creation_expectedClient() {
        let actual = self.client

        XCTAssertNotNil(actual)
    }

    func test_addingOneStub() {
        let client = self.client

        _ = client.add(RequestStub(url: url, method: .get), stub: stub)
    }

    func test_addingManyStubs() {
        let client = self.client

        let stubItem = RequestStubMap(url: url, method: .get, query: nil, body: nil, responseStub: stub)
        let secondStubItem = RequestStubMap(url: url, method: .post, query: nil, body: nil, responseStub: stub)
        let stubs = [stubItem]
        let secondStubs = [secondStubItem]

        client.add(stubsArray: stubs)
        client.add(stubsArray: secondStubs)
    }

    func test_detectExistingMockOnUnconfiguredClient_expectedFalse() {
        let client = self.client

        let actual = client.hasStub(RequestStub(url: URL(string: "some_url/") ?? URL(fileURLWithPath: ""), method: .get))

        XCTAssertFalse(actual)
    }

    func test_detectExistingMockOnConfiguredClient_expectedTrue() {
        let url = URL(string: "some_url/") ?? URL(fileURLWithPath: "")
        let method = HTTPMethod.get

        let client = self.client
        let key = RequestStub(url: url, method: method, body: ["key": 1])
        client.add(key, stub: stub)

        XCTAssertTrue(client.hasStub(key))
    }

    func test_removingStubByMethod_expectedFalse() {
        let method = HTTPMethod.get

        let key = RequestStub(url: self.url, method: method, body: nil)
        let client = self.client
        client.add(key, stub: self.stub)
        client.remove(key)

        XCTAssertFalse(client.hasStub(key))
    }

    struct MMMRequest: NetworkRequest {

        var URL: URLConvertible {
            return "method"
        }

        var responseSerializer: StringResponseSerializer {
            return ResponseSerializer()
        }
    }

    func test_convertStubToMutaterRaw() {

        let expectedData = self.stub.body
        let expectedStatusCode = self.stub.statusCode
        let expectedHeaders = self.stub.headers
        let method = HTTPMethod.get
        let expectedError = self.stub.error

        let key = RequestStub(url: self.url, method: method)
        let client = self.client
        client.add(key, stub: self.stub)

        let request = MMMRequest()

        let rawTuple = client.response(for: request)
        let response = (rawTuple?.response as? HTTPURLResponse)

        XCTAssertEqual(expectedData?.data, rawTuple?.data)
        XCTAssertEqual(expectedStatusCode, StatusCodes(rawValue: response?.statusCode ?? -1))
        XCTAssertEqual(expectedHeaders ?? [:], (response?.allHeaderFields as? [String: String]) ?? [:])
        XCTAssertEqual(expectedError?.nsError, rawTuple?.error as NSError?)
    }

    func test_stubBodyJSONResponse() {

        let expectedData = ["2": 2, "3": 3]
        do {
            let responseStub = try ResponseStub(bodyJSON: expectedData)
            let expectedStatusCode = responseStub.statusCode
            let expectedHeaders = responseStub.headers
            let method = HTTPMethod.get
            let expectedError = responseStub.error

            let key = RequestStub(url: self.url, method: method)
            let client = self.client
            client.add(key, stub: responseStub)

            let request = MMMRequest()

            let rawTuple = client.response(for: request)
            let response = (rawTuple?.response as? HTTPURLResponse)

            XCTAssertEqual(responseStub.body?.data, rawTuple?.data)
            XCTAssertEqual(expectedStatusCode, StatusCodes(rawValue: response?.statusCode ?? -1))
            XCTAssertEqual(expectedHeaders ?? [:], (response?.allHeaderFields as? [String: String]) ?? [:])
            XCTAssertEqual(expectedError?.nsError, rawTuple?.error as NSError?)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_gettingNotExistsStub_expectedError() {
        let client = self.client
        client.notFoundStubBehavior = .giveError
        let request = MMMRequest()
        guard let rawTuple = client.response(for: request) else {
            XCTFail(" ")

            return
        }

        XCTAssertNil(rawTuple.data)
        XCTAssertNotNil(rawTuple.error)
        guard let response = rawTuple.response as? HTTPURLResponse else {
            XCTFail(" ")

            return
        }

        XCTAssertEqual(404, response.statusCode)

        guard let headers = response.allHeaderFields as? [String: String] else {
            XCTFail(" ")

            return
        }

        XCTAssertEqual([:], headers)
    }

    func test_gettingNotExistsStub_expectedNil() {
        let client = self.client
        client.notFoundStubBehavior = .useRealClient
        let request = MMMRequest()

        let rawTuple = client.response(for: request)

        XCTAssertNil(rawTuple)
    }
}
