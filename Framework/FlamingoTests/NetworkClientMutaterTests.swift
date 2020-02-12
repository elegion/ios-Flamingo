//
//  NetworkClientMutaterTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 24.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import XCTest
import Flamingo

private final class MockEmptyMutater: NetworkClientMutater {
    var responseReplaceWasCalled: Bool = false
    var wasCalledClosure: (() -> Void)?

    func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request: NetworkRequest {
        responseReplaceWasCalled = true
        wasCalledClosure?()
        return nil
    }
}

private func == (lhs: [String: Any]?, rhs: [String: Any]?) -> Bool {

    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case let (.some(left), .some(right)):
        return NSDictionary(dictionary: left).isEqual(to: right)
    default:
        return false
    }
}

private final class MockMutater: NetworkClientMutater {
    let mockableRequest = RealFailedTestRequest()
    let testData = "Response is mocked"
    let testStatusCode = 212

    func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request: NetworkRequest {
        guard request.URL == mockableRequest.URL &&
            request.body?.parameters == mockableRequest.body?.parameters &&
            request.baseURL == mockableRequest.baseURL else {
                return nil
        }
        
        do {
            let response = HTTPURLResponse(url: try request.URL.asURL(),
                                           statusCode: testStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            
            let data = testData.data(using: .utf8)
            
            return (data, response, nil)
        } catch {
            return nil
        }
    }
}

final class NetworkClientMutaterTests: XCTestCase {
    
    var networkClient: NetworkDefaultClient {
        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/")
        return NetworkDefaultClient(configuration: configuration, session: .shared)
    }

    func test_mutaterCalls() {
        let mutater1 = MockEmptyMutater()
        let mutater2 = MockEmptyMutater()

        let networkClient = self.networkClient
        networkClient.addMutater(mutater1)
        networkClient.addMutater(mutater2)

        let asyncExpectation = expectation(description: #function)

        networkClient.removeMutater(mutater2)
        let request = RealFailedTestRequest()
        networkClient.sendRequest(request) { _, _ in
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { _ in
            XCTAssertTrue(mutater1.responseReplaceWasCalled)
            XCTAssertFalse(mutater2.responseReplaceWasCalled)
        }
    }

    func test_mutateAndPriority() {
        let mutater0 = MockEmptyMutater()
        let mutater1 = MockMutater()
        let mutater2 = MockEmptyMutater()
        let networkClient = self.networkClient

        networkClient.addMutater(mutater0)
        networkClient.addMutater(mutater1)
        networkClient.addMutater(mutater2)

        let asyncExpectation = expectation(description: #function)
        let request = RealFailedTestRequest()
        let operation = networkClient.sendRequest(request) {
            result, context in

            switch result {
            case .success(let value):
                XCTAssert(value == mutater1.testData, "Wrong replace data")
                XCTAssertEqual(context?.response?.statusCode, mutater1.testStatusCode)
            case .failure(let error):
                XCTFail("No error expected, error \(error)")
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) {
            _ in

            if let task = operation as? URLSessionTask {
                XCTFail("Task shouldn't be called")
                XCTAssertNotEqual(task.state, .completed)
            }
            XCTAssertTrue(mutater0.responseReplaceWasCalled)
            XCTAssertFalse(mutater2.responseReplaceWasCalled)
        }
    }

    func test_notParallelJobs() {
        let mutater0 = MockMutater()

        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/", parallel: false)
        let networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
        networkClient.addMutater(mutater0)

        var wasCalledResponse = false
        let request = RealFailedTestRequest()
        networkClient.sendRequest(request) {
            _, _ in

            wasCalledResponse = true
        }

        XCTAssertTrue(wasCalledResponse)
    }

    func test_storagePolicy() {
        var wasCalled1 = false
        var wasCalled2 = false
        var mutater1: MockEmptyMutater! = MockEmptyMutater()
        var mutater2: MockEmptyMutater! = MockEmptyMutater()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/", parallel: false)
        let networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
        networkClient.addMutater(mutater1, storagePolicy: .weak)
        networkClient.addMutater(mutater2, storagePolicy: .strong)
        mutater1.wasCalledClosure = {
            wasCalled1 = true
        }
        mutater2.wasCalledClosure = {
            wasCalled2 = true
        }
        mutater1 = nil
        mutater2 = nil

        let stubRequest = StubRequest()
        networkClient.sendRequest(stubRequest, completionHandler: nil)
        XCTAssertFalse(wasCalled1)
        XCTAssertTrue(wasCalled2)
    }
}
