//
//  JSONSerializerTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

private struct SomeStruct: Comparable, Equatable, Decodable {
    var key: String

    static func == (lhs: SomeStruct, rhs: SomeStruct) -> Bool {
        return lhs.key == rhs.key
    }

    static func < (lhs: SomeStruct, rhs: SomeStruct) -> Bool {
        return lhs.key < rhs.key
    }
}

class JSONSerializerTestCase: XCTestCase {
    private var serializer: JSONSerializer {
        return JSONSerializer()
    }

    private var jsonString: String {
        return "{\"key\": \"value\"}"
    }

    private var jsonData: Data {
        return self.jsonString.data(using: .utf8)!
    }

    private var defaultExpected: SomeStruct {
        return SomeStruct(key: "value")
    }

    public func test_createSerializer() {
        let serializer = self.serializer

        XCTAssertNotNil(serializer)
    }

    public func test_deserializeString() {
        let serializer = self.serializer
        let actual: Result<SomeStruct> = serializer.deserialize(string: self.jsonString)

        XCTAssertEqual(self.defaultExpected, actual.value!)
    }

    public func test_deserializeWrongString() {
        let serializer = self.serializer
        let actual: Result<SomeStruct> = serializer.deserialize(string: "")

        XCTAssertFalse(actual.isSuccess)
    }

    public func test_deserializeData() {
        let serializer = self.serializer
        let actual: Result<SomeStruct> = serializer.deserialize(data: self.jsonData)

        XCTAssertEqual(self.defaultExpected, actual.value!)
    }

}
