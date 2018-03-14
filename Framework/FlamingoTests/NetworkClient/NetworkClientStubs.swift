//
//  NetworkClientStubs.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

private class StubsManagerMock: StubsManager {

    public var affected = false

    internal var hasMockAnswer: Bool = false

    func add(_ key: RequestStub, stub: ResponseStub) {

    }

    func add(stubs: Stubs) {

    }

    func remove(_ key: RequestStub) {

    }

    func hasStub(_ key: RequestStub) -> Bool {
        return self.hasMockAnswer
    }

    func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request: NetworkRequest {

        self.affected = true

        let url = URL(fileURLWithPath: "")
        if self.hasMockAnswer {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])
            return (response_body().data(using: .utf8), response, nil)
        } else {
            return (nil, nil, StubError.stubClientError(.stubNotFound))
        }
    }
}

private func api_method() -> String {
    return "index.html"
}

private func response_body() -> String {
    return "{\"field\":\"value\"}"
}

private struct TestModel: Decodable, Equatable {
    var field: String

    static func == (lhs: TestModel, rhs: TestModel) -> Bool {
        return lhs.field == rhs.field
    }
}

private struct TestRequest: NetworkRequest {
    var URL: URLConvertible {
        return api_method()
    }

    var responseSerializer: CodableJSONSerializer<TestModel> {
        return CodableJSONSerializer()
    }
}

class NetworkClientStubs: XCTestCase {
    private var stubClient: StubsManager {
        return StubsManagerMock()
    }

    private var client: NetworkDefaultClientStubs {
        return NetworkDefaultClientStubs.defaultForTest()
    }

    private var configuredClient: NetworkDefaultClientStubs {

        let client = NetworkDefaultClientStubs.defaultForTest()
        let stubs = self.stubClient
        client.stubsManager = stubs

        return client
    }

    public func test_setStubClient() {
        _ = self.configuredClient
    }

    public func test_enableStubs() {
        let client = self.configuredClient

        client.enableStubs()
    }

    public func test_disableStubs() {
        let client = self.configuredClient

        client.disableStubs()
    }

//    public func test_getStubOnNotConfiguredClient_expectedError() {
//        let expectation = self.expectation(description: #function)
//        let client = self.client
//        client.enableStubs()
//
//        let request = TestRequest()
//        client.sendRequest(request) {
//            result, _ in
//
//            guard let errorInRes = result.error,
//                case let Flamingo.Error.networkClientError(error) = errorInRes else {
//                    XCTFail("Wrong error!")
//                    expectation.fulfill()
//                    return
//            }
//
//            XCTAssertTrue(true)
//
//            expectation.fulfill()
//        }
//
//        self.waitForExpectations(timeout: 5, handler: nil)
//    }

    public func test_getStub_expectedResponse() {
        let expectation = self.expectation(description: #function)

        let client = self.configuredClient
        client.enableStubs()

        let request = TestRequest()
        client.sendRequest(request) {
            _, _ in
            
            let stubs = (client.stubsManager as? StubsManagerMock)
            XCTAssertTrue(stubs?.affected ?? false)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

//    public func test_changingToRealClientOnNotExistsStub_expectedSwiftError() {
//        let expectation = self.expectation(description: #function)
//        let client = self.configuredClient
//        client.enableStubs()
//        (client.StubsManager as? StubsManagerMock)?.hasMockAnswer = false
//
//        let request = TestRequest()
//        client.sendRequest(request) {
//            _, context in
//
//            XCTAssertNotNil(context?.error)
//            XCTAssertTrue(context?.error is Swift.DecodingError, "\(context?.error?.localizedDescription ?? "")")
//
//            expectation.fulfill()
//        }
//
//        self.waitForExpectations(timeout: 5, handler: nil)
//    }

    public func test_gettingResponseOnExistingStub_expectedResponse() {
        let expectation = self.expectation(description: #function)
        let client = self.configuredClient
        client.enableStubs()
        (client.stubsManager as? StubsManagerMock)?.hasMockAnswer = true

        let request = TestRequest()
        client.sendRequest(request) { result, _ in
            XCTAssertTrue(result.isSuccess)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

}
