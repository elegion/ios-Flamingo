//
//  DataResponseSerializerTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 02-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class DataResponseSerializerTestCase: XCTestCase {

    enum SomeError: Swift.Error {
        case error
    }

    private var serializer: DataResponseSerializer {
        return DataResponseSerializer()
    }

    private let request: URLRequest? = nil
    private let response: HTTPURLResponse? = nil

    public func test_serializeData_expectedValidData() {
        let serializedData = Data()
        let error: SomeError? = nil
        let expected = serializedData

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        XCTAssertEqual(expected, actual.value!)
    }

    public func test_serializeDataWithError_expectedError() {
        let serializedData: Data? = nil
        let error = SomeError.error
        let expected = error

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        XCTAssertEqual(expected, (actual.error! as? SomeError)!)
    }

    public func test_serializeDataNoErrorNoData_expectedError() {
        let serializedData: Data? = nil
        let error: SomeError? = nil
        let expected = Flamingo.Error.unableToRetrieveDataAndError

        let actual = self.serializer.serialize(request: self.request,
                                               response: self.response,
                                               data: serializedData,
                                               error: error)

        XCTAssertTrue((expected as NSError).isEqual(actual.error! as NSError))
    }
}
