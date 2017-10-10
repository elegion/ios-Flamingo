//
//  ResultTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 29-09-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class ResultTestCase: XCTestCase {
    private enum StubError: Swift.Error {
        case someError
    }

    private struct Consts {
        static let successValue = "success value"
    }

    private func successResult() -> Result<String> {
        return .success(Consts.successValue)
    }

    private func errorResult() -> Result<String> {
        return .error(StubError.someError)
    }

    public func test_checkGettingValueOnSuccessResult_expectedValueInstance() {
        let expected = Consts.successValue
        let actual = successResult().value

        XCTAssertEqual(expected, actual)
    }

    public func test_checkGettingValueOnErrorResult_expectedNil() {
        let actual = errorResult().value

        XCTAssertNil(actual)
    }

    public func test_checkGettingErrorOnSuccessResult_expectedNil() {
        let actual = successResult().error

        XCTAssertNil(actual)

    }

    public func test_checkGettingErrorOnErrorResult_expectedErrorInstance() {
        let expected = StubError.someError
        let actual = (errorResult().error as? StubError)!

        XCTAssertEqual(expected, actual)
    }

    public func test_checkingSuccessOnSuccessResult_expectedTrue() {
        let actual = successResult().isSuccess

        XCTAssertTrue(actual)
    }

    public func test_checkingSuccessOnErrorResult_expectedFalse() {
        let actual = errorResult().isSuccess

        XCTAssertFalse(actual)
    }
}
