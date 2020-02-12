//
//  FormURLParametersEncoderTestCase.swift
//  FlamingoTests
//
//  Created by Egor Snitsar on 12.02.2020.
//  Copyright © 2020 ELN. All rights reserved.
//

import XCTest
import Flamingo

final class FormURLParametersEncoderTestCase: XCTestCase {

    private let urlString: String = "http://e-legion.com"

    private var request: URLRequest {
        let url = URL(string: self.urlString) ?? URL(fileURLWithPath: "")

        return URLRequest(url: url)
    }

    private var encoder: ParametersEncoder {
        return FormURLParametersEncoder()
    }

    private var data: [String: Any] {
        return [
            "root": [
                "dictionary": [
                    "key&1": "value1",
                    "key2": "value2",
                    "key3": "value3",
                ],
            ],
            "key": "value",
        ]
    }

    func test_encodeDataAndSetToHttpBody_expectedValidData() {
        let expected = self.data

        var request = self.request
        let encoder = self.encoder

        do {
            try encoder.encode(parameters: expected, to: &request)

            if let body = request.httpBody {
                let expectedString = "key=value&root%5Bdictionary%5D%5Bkey%261%5D=value1&root%5Bdictionary%5D%5Bkey2%5D=value2&root%5Bdictionary%5D%5Bkey3%5D=value3"
                let resultString = String(data: body, encoding: .utf8)

                XCTAssertEqual(resultString, expectedString)
            } else {
                XCTFail(" ")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_serializingNilParameters_expectedNil() {
        var request = self.request
        let encoder = self.encoder
        let parameters: [String: Any]? = nil

        do {
            try encoder.encode(parameters: parameters, to: &request)

            XCTAssertNil(request.httpBody)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
