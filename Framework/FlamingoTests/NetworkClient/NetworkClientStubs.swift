//
//  NetworkClientStubs.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

private final class StubsManagerMock: StubsManager {

    var affected = false
    var hasMockAnswer: Bool = false
    var error: Swift.Error?
    var notFoundStubBehavior: NotFoundStubBehavior = .giveError

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
            if let error = error {
                return (nil, nil, error)
            } else {
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])
                return (response_body().data(using: .utf8), response, nil)
            }
        } else {
            switch notFoundStubBehavior {
            case .giveError:
                return (nil, nil, StubsError.stubClientError(.stubNotFound))
            case .useRealClient:
                return nil
            }
        }
    }

    private func api_method() -> String {
        return "index.html"
    }

    private func response_body() -> String {
        return "{\"field\":\"value\"}"
    }
}

private struct TestModel: Decodable, Equatable {
    
    var field: String

    static func == (lhs: TestModel, rhs: TestModel) -> Bool {
        return lhs.field == rhs.field
    }
}

private struct TestRequest: NetworkRequest {
    
    var URL: URLConvertible {
        return "index.html"
    }

    var responseSerializer: CodableJSONSerializer<TestModel> {
        return ResponseSerializer()
    }
}

final class NetworkClientStubsTests: XCTestCase {
    
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

    func test_setStubClient() {
        _ = self.configuredClient
    }

    func test_enableStubs() {
        let client = self.configuredClient

        client.enableStubs()
    }

    func test_disableStubs() {
        let client = self.configuredClient

        client.disableStubs()
    }

    func test_getStubOnNotConfiguredClient_expectedError() {
        let expectation = self.expectation(description: #function)
        let client = self.client
        client.stubsManager = nil
        client.enableStubs()

        let request = TestRequest()
        client.sendRequest(request) {
            result, _ in

            do {
                XCTAssertThrowsError(try result.get())
                _ = try result.get()
            } catch {
                XCTAssertTrue(error is Swift.DecodingError, error.localizedDescription)
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    func test_getStub_expectedResponse() {
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

    func test_changingToRealClientOnNotExistsStub_expectedSwiftError() {
        let expectation = self.expectation(description: #function)
        let client = self.configuredClient
        client.enableStubs()
        (client.stubsManager as? StubsManagerMock)?.notFoundStubBehavior = .useRealClient
        (client.stubsManager as? StubsManagerMock)?.hasMockAnswer = false

        let request = TestRequest()
        client.sendRequest(request) {
            result, _ in

            do {
                XCTAssertThrowsError(try result.get())
                _ = try result.get()
            } catch {
                XCTAssertTrue(error is Swift.DecodingError, error.localizedDescription)
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    func test_expectingStubsError() {
        let expectation = self.expectation(description: #function)
        let client = self.configuredClient
        client.enableStubs()
        (client.stubsManager as? StubsManagerMock)?.hasMockAnswer = false
        (client.stubsManager as? StubsManagerMock)?.notFoundStubBehavior = .giveError

        let request = TestRequest()
        client.sendRequest(request) {
            result, _ in

            do {
                XCTAssertThrowsError(try result.get())
                _ = try result.get()
            } catch {
                XCTAssertTrue(error is StubsError, error.localizedDescription)
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    func test_gettingResponseOnExistingStub_expectedResponse() {
        let expectation = self.expectation(description: #function)
        let client = self.configuredClient
        client.enableStubs()
        (client.stubsManager as? StubsManagerMock)?.hasMockAnswer = true

        let request = TestRequest()

        client.sendRequest(request, completionHandler: { result, _ in
            do {
                XCTAssertNoThrow(try result.get())
                _ = try result.get()
            } catch {
                XCTFail("Never")
            }

            expectation.fulfill()
        })

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    struct SimpleObject: Codable {
        let id: Int
        let string: String
        let double: Double
    }

    struct SimpleRequest: NetworkRequest {
        
        var URL: URLConvertible {
            return "some_url.htm"
        }

        var responseSerializer: CodableJSONSerializer<SimpleObject> {
            return ResponseSerializer()
        }
    }

    func test_stubJSONBodyResponse() {
        let client = self.client
        client.stubsManager = nil
        let stubs = StubsDefaultManager()

        let request = SimpleRequest()
        let body: [String: Any] = [
            "id": 2,
            "string": "some",
            "double": 3.0,
        ]
        
        if let requestStub = RequestStub(request),
            let responseStub = try? ResponseStub(bodyJSON: body) {
            client.addMutater(stubs)

            stubs.add(requestStub, stub: responseStub)
            client.sendRequest(request, completionHandler: {
                result, _ in

                let value = try? result.get()
                XCTAssertNotNil(value)
                XCTAssertEqual(value?.id, 2)
                XCTAssertEqual(value?.string, "some")
                XCTAssertEqual(value?.double, 3.0)
            })
        } else {
            XCTFail(" ")
        }
    }
}
