//
//  URLParametersEncoderTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 18-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

class URLParametersEncoderTestCase: XCTestCase {
    private var encoder: ParametersEncoder {
        return URLParametersEncoder()
    }

    private var urlString: String {
        return "http://127.0.0.1"
    }

    private func request(_ query: String = "") -> URLRequest {
        if let url = URL(string: self.urlString + query) {

            return URLRequest(url: url)
        }
        return URLRequest(url: URL(fileURLWithPath: "/"))
    }

    public func test_constructingQueryWithData_expectsUrlWithQuery() {
        // swiftlint:disable line_length
        let expected = self.urlString + "?root%5Bdictionary%5D%5Bkey2%5D=value2&root%5Bdictionary%5D%5Bkey%261%5D=value1&root%5Bdictionary%5D%5Bkey3%5D=value3&root%5Barray%5D%5B%5D=1&root%5Barray%5D%5B%5D=2&root%5Barray%5D%5B%5D=3&root%5Bnested_dictionary%5D%5Bdictionary2%5D%5Bkey5%5D=5&root%5Bnested_dictionary%5D%5Bdictionary2%5D%5Bkey6%5D=0&root%5Bnested_dictionary%5D%5Bdictionary2%5D%5Bkey4%5D=value4&root%5Bint%5D=12&root%5Bbool%5D=1&root%5Bstring%5D=string!@%23$%25%5E%26*()_+%3D-%5B%5D%7B%7D;'%22:,./%3C%3E?%60~%5C"
        // swiftlint:enable line_length
        let data: [String: Any] = [
            "root": [
                "dictionary": [
                    "key&1": "value1",
                    "key2": "value2",
                    "key3": "value3",
                ],
                "array": [ 1, 2, 3 ],
                "nested_dictionary": [
                    "dictionary2": [
                        "key4": "value4",
                        "key5": 5,
                        "key6": false,
                    ],
                    "dictionary3": nil,
                ],
                "int": 12,
                "bool": true,
                "string": "string!@#$%^&*()_+=-[]{};'\":,./<>?`~\\",
                "null": nil,
            ],
        ]

        var request = self.request()
        let encoder = self.encoder

        do {
            try encoder.encode(parameters: data, to: &request)

            let actual = request.url?.absoluteString

            XCTAssertEqual(expected, actual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    public func test_construcingQueryByNil_expectsOnlyUrl() {
        let expected = self.urlString

        let data: [String: Any]? = nil

        var request = self.request()
        let encoder = self.encoder

        do {
            try encoder.encode(parameters: data, to: &request)

            let actual = request.url?.absoluteString

            XCTAssertEqual(expected, actual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    public func test_appendingQuery_expectsAllDataInUrl() {
        let query = "?some_query"
        let expected = URL(string: self.urlString + "?some_query&key=value")?.absoluteString ?? ""

        let data = [
            "key": "value",
        ]

        var request = self.request(query)
        let encoder = self.encoder

        do {
            try encoder.encode(parameters: data, to: &request)

            let actual = request.url?.absoluteString

            XCTAssertEqual(expected, actual)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
