//
//  FlamingoTests.swift
//  FlamingoTests
//
//  Created by Nikolay Ischuk on 25.09.17.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class RealFailedTestRequest: NetworkRequest {

    var URL: URLConvertible {
        return "v2/59c956433f0000910183f797"
    }

    var method: HTTPMethod {
        return .put
    }

    var parameters: [String: Any]? {
        return ["some_param": 12]
    }

    var parametersEncoder: ParametersEncoder {
        return JSONParametersEncoder()
    }

    typealias ResponseSerializer = StringResponseSerializer

    var responseSerializer: ResponseSerializer {
        return ResponseSerializer()
    }
}

class ValidationTests: XCTestCase {

    var client: NetworkClient!

    override func setUp() {
        super.setUp()
        let configuration = NetworkDefaultConfiguration(baseURL: "http://www.mocky.io/")
        client = NetworkDefaultClient(configuration: configuration, session: .shared)
    }

    override func tearDown() {
        client = nil
        super.tearDown()
    }

    func testResponseStatusCode() {

        let asyncExpectation = expectation(description: "Async")

        let request = RealFailedTestRequest()
        client.sendRequest(request) {
            result, context in

            switch result {
            case .success:
                XCTFail("Should be error")
            case .error(let error):
                if let statusCode = context?.response?.statusCode {
                    XCTAssertEqual(statusCode, 301, "Not correct status code")
                } else {
                    XCTFail("Should be another error, \(error)")
                }
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (_) in }
    }

    func testValidationByMimeType() {
        guard let url = URL(string: "https://e-legion.com") else {
            XCTFail(" ")
            return
        }

        guard let response = MockResponse(url: url, mimeType: "mimeType") else {
            XCTFail(" ")
            return
        }

        guard let data = response.responseData else {
            XCTFail(" ")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("mime/type", forHTTPHeaderField: "Accept")

        let errors = Validator(request: request, response: response, data: data)
            .validate()
            .validationErrors

        XCTAssertTrue(errors.count > 0)
    }

    func testValidationWhenResponseMimeIsNil() {
        guard let url = URL(string: "https://e-legion.com") else {
            XCTFail(" ")
            return
        }

        guard let response = MockResponse(url: url, mimeType: nil) else {
            XCTFail(" ")
            return
        }

        guard let data = response.responseData else {
            XCTFail(" ")
            return
        }

        response.forceMimeType = true
        response.forcedMimeType = nil

        var request = URLRequest(url: url)
        request.addValue("mime/type", forHTTPHeaderField: "Accept")

        let errors = Validator(request: request, response: response, data: data)
            .validate()
            .validationErrors

        XCTAssertTrue(errors.count > 0)
    }
}

private class MockResponse: HTTPURLResponse {
    private struct Consts {
        static let jsonData = "[1,2,3]"
        static var data: Data? {
            return Consts.jsonData.data(using: .utf8)
        }
    }

    override var statusCode: Int {
        return 200
    }

    var forceMimeType: Bool = false
    var forcedMimeType: String?

    override var mimeType: String? {
        return forceMimeType == false
            ? super.mimeType
            : forcedMimeType
    }

    var responseData: Data? {
        return Consts.data
    }

    convenience init?(url: URL, mimeType: String?) {
        guard let unwrappedData = Consts.data else {
            return nil
        }

        self.init(
            url: url,
            mimeType: mimeType,
            expectedContentLength: unwrappedData.count,
            textEncodingName: "UTF-8"
        )
    }
}
