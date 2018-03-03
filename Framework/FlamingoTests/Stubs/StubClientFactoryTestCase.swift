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
    private var method: String {
        return "method"
    }

    private var stub: ResponseStub {
        return ResponseStub(body: Data())
    }

    public func test_simpleCreateClient() {
        let client = StubsSessionFactory.session()

        XCTAssertNotNil(client)
    }

    public func test_createClientWithOneMethod_expectedClient() {
        let client = StubsSessionFactory.session(url: self.method, method: HTTPMethod.get, stub: self.stub)

        XCTAssertNotNil(client)
    }

    public func test_createClientWithDictionary_expectedClient() {
        let stubMethod = RequestStubMap(url: self.method, method: HTTPMethod.get, stub: self.stub)
        let client = StubsSessionFactory.session(with: [stubMethod])

        XCTAssertNotNil(client)
    }

    public func test_createFromNotExistsFile_expectedException() {
        let expectedFileName = "not exists file"

        XCTAssertException(
            _ = try StubsSessionFactory.session(fromFile: expectedFileName),
            expectedError: Flamingo.Error.stubClientFactoryError(.fileNotExists(expectedFileName))
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
            XCTFail(" ")
        }
    }

    public func test_mappingFromFileWithBadFormat_expectedClient() {
        guard let expectedFileName = expectedFileFor("WrongList.json") else {
            XCTFail(" ")
            return
        }

        XCTAssertException(
            _ = try StubsSessionFactory.session(fromFile: expectedFileName),
            expectedError: Flamingo.Error.stubClientFactoryError(.wrongListFormat)
        )
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
