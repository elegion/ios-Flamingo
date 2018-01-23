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
    public let context = NetworkContext(request: nil, response: nil, data: nil, error: nil)

    private var reporters = ObserversArray<NetworkClientReporter>()

    func sendRequest<Request: NetworkRequest>(_ networkRequest: Request,
                                              completionHandler: ((Result<Request.Response>, NetworkContext?) -> Void)?) -> CancelableOperation? {
        self.sendRequestExecuted = true
        self.queue.async {
            [weak self] in
            guard let sself = self else {
                return
            }
            sself.reporters.invoke(invocation: {
                (reporter) in
                reporter.didRecieveResponse(for: networkRequest, context: sself.context)
            })
            completionHandler?((sself.responseResult as? Result<Request.Response>)!, sself.context)
        }

        return nil
    }

    func addReporter(_ reporter: NetworkClientReporter) {
        reporters.addObserver(observer: reporter)
    }

    func removeReporter(_ reporter: NetworkClientReporter) {
        reporters.removeObserver(observer: reporter)
    }
}

private class MockLogger: Logger {
    private(set) var logSended: Bool = false

    public func log(_ message: String, context: [String: Any]?) {
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

    private func client(_ mockClient: NetworkClient? = nil,
                        logger mockLogger: Logger? = nil) -> (NetworkClient, LoggingClient) {
        let client = mockClient ?? self.configuredMockClient
        let logger = mockLogger ?? self.mockLogger
        let loggingClient = LoggingClient(logger: logger)
        loggingClient.useLogger = true
        client.addReporter(loggingClient)

        return (client, loggingClient)
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
        let clients = self.client(mockClient)
        let request = self.request

        _ = clients.0.sendRequest(request) { _, _ in
            XCTAssertTrue(mockClient.sendRequestExecuted)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_checkLogging_expectedTrue() {
        let expectation = self.expectation(description: #function)
        let mockLogger = self.mockLogger
        let clients = self.client(logger: mockLogger)
        let request = self.request

        _ = clients.0.sendRequest(request) { _, _ in
            XCTAssertTrue(mockLogger.logSended)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_disableLogging_expectedFalse() {
        let expectation = self.expectation(description: #function)
        let logger = self.mockLogger
        let clients = self.client(logger: logger)
        clients.1.useLogger = false
        let request = self.request

        _ = clients.0.sendRequest(request) { _, _ in
            XCTAssertFalse(logger.logSended)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    public func test_saveDisablingForRequest_expectedFalse() {
        let expectation = self.expectation(description: #function)
        let logger = self.mockLogger
        let clients = self.client(logger: logger)
        clients.1.useLogger = false
        let request = self.request

        _ = clients.0.sendRequest(request) { _, _ in
            XCTAssertFalse(logger.logSended)

            expectation.fulfill()
        }

        clients.1.useLogger = true

        self.waitForExpectations(timeout: 5, handler: nil)
    }
}
