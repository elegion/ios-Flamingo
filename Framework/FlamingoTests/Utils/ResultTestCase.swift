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

    public func test_checkGettingValue_onSuccess() {
        let expected = Consts.successValue
        let actual = successResult().value

        XCTAssertEqual(expected, actual)
    }

    public func test_checkGettingValue_onError() {
        let actual = errorResult().value

        XCTAssertNil(actual)
    }

    public func test_checkGettingError_onSuccess() {
        let actual = successResult().error

        XCTAssertNil(actual)

    }

    public func test_checkGettingError_onError() {
        let expected = StubError.someError
        let actual = (errorResult().error as? StubError)!

        XCTAssertEqual(expected, actual)
    }

    public func test_checkingSuccess_onSuccess() {
        let actual = successResult().isSuccess

        XCTAssertTrue(actual)
    }

    public func test_checkingSuccess_onError() {
        let actual = errorResult().isSuccess

        XCTAssertFalse(actual)
    }
}
