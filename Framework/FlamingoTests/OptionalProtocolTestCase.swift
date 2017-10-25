//
//  OptionalProtocolTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 20-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class OptionalProtocolTestCase: XCTestCase {
    private struct Consts {
        static let optionalValue = 5
    }

    private var optionalSome: Int? {
        return Consts.optionalValue
    }

    private var optionalNone: Int? {
        return nil
    }

    public func test_isSomeOnSome_expectedTrue() {
        let actual = self.optionalSome.isSome()

        XCTAssertTrue(actual)
    }

    public func test_isSomeOnNone_expectedFalse() {
        let actual = self.optionalNone.isSome()

        XCTAssertFalse(actual)
    }

    public func test_isNoneOnNone_expectedTrue() {
        let actual = self.optionalNone.isNone()

        XCTAssertTrue(actual)
    }

    public func test_isNoneOnSome_expectedFalse() {
        let actual = self.optionalSome.isNone()

        XCTAssertFalse(actual)
    }

    public func test_getValueOnSome_expectedValue() {
        let expected = Consts.optionalValue
        let actual = self.optionalSome.value

        XCTAssertEqual(expected, (actual as? Int)!)
    }
}
