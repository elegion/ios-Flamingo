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

    private var request: URLRequest {
        let url = URL(string: self.urlString) ?? URL(fileURLWithPath: "")

        return URLRequest(url: url)
    }

    private var encoder: ParametersEncoder {
        return JSONParametersEncoder()
    }

    private var data: DataType {
        return [
            "root": [
                "dictionary": [
                    "key&1": "value1",
                    "key2": "value2",
                    "key3": "value3",
                ],
            ],
        ]
    }

    public func test_encodeDataAndSetToHttpBody_expectedValidJSON() {
        let expected = self.data

        var request = self.request
        let encoder = self.encoder

        do {
            try encoder.encode(parameters: expected, to: &request)

            if let body = request.httpBody {
                let data = try JSONSerialization.jsonObject(with: body, options: [])

                XCTAssertNotNil(data)
            } else {
                XCTFail(" ")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    public func test_encodeDataAndSetToHttpBody_expectedSameDataAsInitialValue() {
        let expected = self.data

        var request = self.request
        let encoder = self.encoder

        do {
            try? encoder.encode(parameters: expected, to: &request)

            let decoder = JSONDecoder()
            guard let body = request.httpBody else {
                XCTFail(" ")
                return
            }
            let actual = try decoder.decode(DataType.self, from: body)

            XCTAssertTrue((expected as NSDictionary).isEqual(to: actual))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
