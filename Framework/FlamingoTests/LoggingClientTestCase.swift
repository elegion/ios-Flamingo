//
//  LoggingClientTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 11-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

private class MockClient: NetworkClient {
    private(set) var sendRequestExecuted: Bool = false
    private var queue: DispatchQueue {
        return DispatchQueue(label: "com.e-legion.test.queue", attributes: .concurrent)
    }

    public var responseResult: Result<StubModel>?
    public var context: NetworkContext?

    func sendRequest<Request: NetworkRequest>(_ networkRequest: Request, completionHandler: ((Result<Request.Response>, NetworkContext?) -> Void)?) -> CancelableOperation? {
        self.sendRequestExecuted = true
        self.queue.async {
            completionHandler?((self.responseResult! as? Result<Request.Response>)!, self.context)
        }

        return nil
    }
}

private class MockLogger: Logger {
    private(set) var logSended: Bool = false

    public func log(_ message: String, context: [String: Any?]?) {
        self.logSended = true
    }
}

private struct StubModel: Decodable {
    var field: Int
}

private struct StubRequest: NetworkRequest {
    var responseSerializer: CodableJSONSerializer<StubModel> {
        return CodableJSONSerializer()
    }

    var URL: URLConvertible {
        return "/"
    }
}

class LoggingClientTestCase: XCTestCase {
    private var mockLogger: MockLogger {
        return MockLogger()
    }

    private var mockClient: MockClient {
        return MockClient()
    }

    private var configuredMockClient: MockClient {
        let client = self.mockClient
        client.responseResult = .success(self.stubModel)

        return client
    }

    private var stubModel: StubModel {
        return StubModel(field: 0)
    }

    private func client(_ mockClient: NetworkClient? = nil, logger mockLogger: Logger? = nil) -> LoggingClient {
        let client = mockClient ?? self.configuredMockClient
        let logger = mockLogger ?? self.mockLogger
        let loggingClient = LoggingClient(for: client, logger: logger)
        loggingClient.enableLogging()

        return loggingClient
    }

    private var request: StubRequest {
        return StubRequest()
    }

    public func test_instanciateLoggingClient_expectedClient() {
        let client = self.client()

        XCTAssertNotNil(client)
    }

    public func test_checkCallingDecoratedClient_expectedTrue() {
        let expectation = self.expectation(description: #function)
        let mockClient = self.mockClient
        mockClient.responseResult = .success(self.stubModel)
        let client = self.client(mockClient)
        let request = self.request

        _ = client.sendRequest(request) { _, _ in
            XCTAssertTrue(mockClient.sendRequestExecuted)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_checkLogging_expectedTrue() {
        let expectation = self.expectation(description: #function)
        let mockLogger = self.mockLogger
        let client = self.client(logger: mockLogger)
        let request = self.request

        _ = client.sendRequest(request) { _, _ in
            XCTAssertTrue(mockLogger.logSended)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_disableLogging_expectedFalse() {
        let expectation = self.expectation(description: #function)
        let logger = self.mockLogger
        let client = self.client(logger: logger)
        client.disableLogging()
        let request = self.request

        _ = client.sendRequest(request) { _, _ in
            XCTAssertFalse(logger.logSended)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_saveDisablingForRequest_expectedFalse() {
        let expectation = self.expectation(description: #function)
        let logger = self.mockLogger
        let client = self.client(logger: logger)
        client.disableLogging()
        let request = self.request

        _ = client.sendRequest(request) { _, _ in
            XCTAssertFalse(logger.logSended)

            expectation.fulfill()
        }

        client.enableLogging()

        self.waitForExpectations(timeout: 5, handler: nil)
    }
}
