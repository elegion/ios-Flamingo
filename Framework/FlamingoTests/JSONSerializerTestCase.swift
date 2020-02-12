//
//  JSONSerializerTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

private struct SomeStruct: Equatable, Decodable {
    var key: String

    static func == (lhs: SomeStruct, rhs: SomeStruct) -> Bool {
        return lhs.key == rhs.key
    }
}

final class JSONSerializerTestCase: XCTestCase {
    
    private var serializer: JSONSerializer {
        return JSONSerializer()
    }

    private var jsonString: String {
        return "{\"key\": \"value\"}"
    }

    private var jsonData: Data {
        return self.jsonString.data(using: .utf8) ?? Data()
    }

    private var defaultExpected: SomeStruct {
        return SomeStruct(key: "value")
    }

    func test_createSerializer() {
        let serializer = self.serializer

        XCTAssertNotNil(serializer)
    }

    func test_deserializeString_expectedValidStruct() {
        let serializer = self.serializer
        let actual: Result<SomeStruct, Error> = serializer.deserialize(string: self.jsonString)

        XCTAssertEqual(self.defaultExpected, try? actual.get())
    }

    func test_deserializeWrongString_expectedErrorResult() {
        let serializer = self.serializer
        let actual: Result<SomeStruct, Error> = serializer.deserialize(string: "")

        XCTAssertThrowsError(try actual.get())
    }

    func test_deserializeData_expectedValidStruct() {
        let serializer = self.serializer
        let actual: Result<SomeStruct, Error> = serializer.deserialize(data: self.jsonData)

        XCTAssertEqual(self.defaultExpected, try? actual.get())
    }
}
