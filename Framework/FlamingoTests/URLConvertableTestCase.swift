//
//  URLConvertableTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 02-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class URLConvertableTestCase: XCTestCase {
    public func test_convertingValidString_expectedURL() {
        let site = "http://e-legion.com/"
        let expected = URL(string: site)

        let actual = try? site.asURL()

        XCTAssertEqual(expected, actual)
    }

    public func test_convertingInvalidString_MustThrowsConversionError() {
        let site = "some string"

        do {
            _ = try site.asURL()
        } catch URLConvertableError.stringToURLConversionError {
            return
        } catch {
            XCTFail("Error `\(error)` raised!")
        }

        XCTFail("Error not raised!")
    }

    public func test_convertingUrl_expectedURL() {
        let expected = URL(string: "http://e-legion.com/")

        do {
            let actual = try expected?.asURL()

            XCTAssertEqual(expected, actual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
