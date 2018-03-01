//
//  StringResponseSerializerTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class StringResponseSerializerTestCase: XCTestCase {
    enum SomeError: Swift.Error {
        case error
    }

    private var serializer: StringResponseSerializer {
        return StringResponseSerializer()
    }

    private let request: URLRequest? = nil
    private let response: HTTPURLResponse? = nil

    public func test_serializeData_expectedValidData() {
        let expected = "string for serialization"
        let serializedData = expected.data(using: .utf8)
        let error: SomeError? = nil

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        XCTAssertEqual(expected, actual.value)
    }

    public func test_serializeDataWithError_expectedError() {
        let serializedData: Data? = nil
        let error = SomeError.error
        let expected = error

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        XCTAssertEqual(expected, (actual.error as? SomeError))
    }

    public func test_serializeDataNoErrorNoData_expectedError() {
        let serializedData: Data? = nil
        let error: SomeError? = nil
        let expected = Flamingo.Error.unableToRetrieveDataAndError

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        guard let actError = actual.error else {
            XCTFail(" ")
            return
        }
        XCTAssertTrue((expected as NSError).isEqual(actError as NSError))
    }

}
