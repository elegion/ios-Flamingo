//
//  StringResponseSerializerTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

final class StringResponseSerializerTestCase: XCTestCase {
    
    enum SomeError: Swift.Error {
        case error
    }

    private var serializer: StringResponseSerializer {
        return StringResponseSerializer()
    }

    private let request: URLRequest? = nil
    private let response: HTTPURLResponse? = nil

    func test_serializeData_expectedValidData() {
        let expected = "string for serialization"
        let serializedData = expected.data(using: .utf8)
        let error: SomeError? = nil

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)
        XCTAssertEqual(expected, try? actual.get())
    }

    func test_serializeDataWithError_expectedError() {
        let serializedData: Data? = nil
        let error = SomeError.error
        let expected = error

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)
        do {
            _ = try actual.get()
            XCTFail("Never")
        } catch {
            XCTAssertEqual(expected, error as? SomeError)
        }
    }

    func test_serializeDataNoErrorNoData_expectedError() {
        let serializedData: Data? = nil
        let error: SomeError? = nil
        let expected = FlamingoError.unableToRetrieveDataAndError

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        do {
            _ = try actual.get()
            XCTFail("Never")
        } catch {
            XCTAssertTrue((expected as NSError).isEqual(error as NSError))
        }
    }
}
