//
//  StubClientFactoryTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

private func expectedFileFor(_ name: String) -> String? {
    return Bundle(for: StubClientFactoryTestCase.self).path(forResource: name, ofType: nil)
}

class StubClientFactoryTestCase: XCTestCase {
    private var url: URL {
        return URL(string: "method")!
    }

    private var stub: ResponseStub {
        return ResponseStub(body: Data())
    }

    public func test_simpleCreateClient() {
        let client = StubsSessionFactory.session()

        XCTAssertNotNil(client)
    }

    public func test_createClientWithOneMethod_expectedClient() {
        let key = RequestStub(url: url, method: .get)
        let client = StubsSessionFactory.session(key, stub: stub)

        XCTAssertTrue(client.hasStub(key))
    }

    public func test_createClientWithDictionary_expectedClient() {
        let stubMethod = RequestStubMap(url: self.url, method: HTTPMethod.get, params: nil, responseStub: self.stub)
        let stubMethod2 = RequestStubMap(url: URL(fileURLWithPath: "\\"), method: HTTPMethod.post, params: ["wqe": 234],
                                         responseStub: self.stub)
        let client = StubsSessionFactory.session(with: [stubMethod, stubMethod2])

        XCTAssertTrue(client.hasStub(stubMethod.requestStub))
        XCTAssertTrue(client.hasStub(stubMethod2.requestStub))
    }

    public func test_createFromNotExistsFile_expectedException() {
        let expectedFileName = "not exists file"

        XCTAssertException(
            _ = try StubsSessionFactory.session(fromFile: expectedFileName),
            expectedError: StubError.stubClientFactoryError(.fileNotExists(expectedFileName))
        )
    }

    public func test_createFromFile_expectedClient() {
        guard let expectedFileName = expectedFileFor("StubsList.json") else {
            XCTFail(" ")
            return
        }

        do {
            let client = try StubsSessionFactory.session(fromFile: expectedFileName)

            XCTAssertNotNil(client)
        } catch {
            XCTFail("\(error)")
        }
    }

    public func test_mappingFromFileWithBadFormat_expectedClient() {
        guard let expectedFileName = expectedFileFor("WrongList.json") else {
            XCTFail(" ")
            return
        }

        do {
            _ = try StubsSessionFactory.session(fromFile: expectedFileName)
            XCTFail(" ")
        } catch {
            XCTAssertTrue(error is Swift.DecodingError)
        }
    }
}

public func XCTAssertException(_ closure: @autoclosure () throws -> Void,
                               expectedError: Swift.Error,
                               message: String? = nil
    ) {
    do {
        try closure()
    } catch {
        let expectedNSError = expectedError as NSError
        let actualNSError = error as NSError

        XCTAssertEqual(expectedNSError, actualNSError)

        return
    }

    XCTFail("Expected exception \(expectedError) but exception not throwed")
}
