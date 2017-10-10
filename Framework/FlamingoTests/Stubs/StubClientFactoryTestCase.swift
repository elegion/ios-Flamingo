//
//  StubClientFactoryTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

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
        let stubMethod = Stub(url: self.method, method: HTTPMethod.get, stub: self.stub)
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
        let expectedFileName = Bundle(for: type(of: self)).path(forResource: "StubsList.json", ofType: nil)!

        let client = (try? StubsSessionFactory.session(fromFile: expectedFileName))!

        XCTAssertNotNil(client)
    }

    public func test_mappingFromFileWithBadFormat_expectedClient() {
        let expectedFileName = Bundle(for: type(of: self)).path(forResource: "WrongList.json", ofType: nil)!

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
