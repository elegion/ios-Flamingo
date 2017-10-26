//
//  JSONParametersEncoderTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 02-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class JSONParametersEncoderTestCase: XCTestCase {

    typealias DataType = [String: [String: [String: String]]]

    private let urlString: String = "http://e-legion.com"

    private func request() -> URLRequest {
        let url = URL(string: self.urlString)!

        return URLRequest(url: url)
    }

    private var encoder: ParametersEncoder {
        return JSONParametersEncoder()
    }

    public func test_() {
        let expected: DataType = [
            "root": [
                "dictionary": [
                    "key&1": "value1",
                    "key2": "value2",
                    "key3": "value3"
                ]
            ]
        ]

        var request = self.request()
        let encoder = self.encoder

        try? encoder.encode(parameters: expected, to: &request)

        let decoder = JSONDecoder()
        let actual = try? decoder.decode(DataType.self, from: request.httpBody!)

        XCTAssertTrue((expected as NSDictionary).isEqual(to: actual!))
    }

}
