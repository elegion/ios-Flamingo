//
//  NetworkClientStubs.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

private class StubsSessionMock: StubsSession {
    public var affected = false

    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> CancelableOperation? {
        DispatchQueue(label: "com.flamingo.operation-queue").async {
            let url = URL(fileURLWithPath: "")
            if self.hasMockAnswer {
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])
                completionHandler(response_body().data(using: .utf8), response, nil)
            } else {
                completionHandler(nil, nil, Flamingo.Error.stubClientError(.stubNotFound))
            }
        }

        self.affected = true

        return nil
    }

    internal var hasMockAnswer: Bool = false

    func add(_ url: String, method: HTTPMethod, stub: ResponseStub) -> Self {
        return self
    }

    func add(stubs: [Stub]) -> Self {
        return self
    }

    func remove(_ url: String, method: HTTPMethod) -> Self {
        return self
    }

    func hasStub(_ url: String, method: HTTPMethod) -> Bool {
        return self.hasMockAnswer
    }

    func hasStub(request: URLRequest) -> Bool {
        return self.hasMockAnswer
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

class NetworkClientStubs: NetworkClientBaseTestCase {
    private var stubClient: StubsSession {
        return StubsSessionMock()
    }

    private var configuredClient: NetworkClient & StubbableClient {
        let client = self.client
        let stubs = self.stubClient
        client.stubs = stubs

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

    public func test_getStub_expectedResponse() {
        let expectation = self.expectation(description: #function)

        let client = self.configuredClient
        client.enableStubs()

        let request = TestRequest()
        client.sendRequest(request) {
            _, _ in
            
            let stubs = (client.stubs as? StubsSessionMock)
            XCTAssertTrue(stubs?.affected ?? false)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_getStubOnNotConfiguredClient_expectedError() {
        let expectation = self.expectation(description: #function)
        let client = self.client
        client.enableStubs()

        let request = TestRequest()
        client.sendRequest(request) {
            result, _ in

            guard let errorInRes = result.error,
                case let Flamingo.Error.networkClientError(error) = errorInRes else {
                XCTFail("Wrong error!")
                expectation.fulfill()
                return
            }

            if error != Flamingo.Error.NetworkClientErrorReason.stubsNotConfigured {
                XCTFail("Wrong error!")
                expectation.fulfill()
                return
            }

            XCTAssertTrue(true)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_changingToRealClientOnNotExistsStub_expectedSwiftError() {
        let expectation = self.expectation(description: #function)
        let client = self.configuredClient
        client.enableStubs()
        client.stubsErrorBehavior = .useRealClient
        (client.stubs as? StubsSessionMock)?.hasMockAnswer = false

        let request = TestRequest()
        client.sendRequest(request) {
            result, error in

            XCTAssertTrue(result.error is Swift.DecodingError)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_gettingResponseOnExistingStub_expectedResponse() {
        let expectation = self.expectation(description: #function)
        let client = self.configuredClient
        client.enableStubs()
        client.stubsErrorBehavior = .useRealClient
        (client.stubs as? StubsSessionMock)?.hasMockAnswer = true

        let request = TestRequest()
        client.sendRequest(request) { result, _ in
            XCTAssertTrue(result.isSuccess)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

}
