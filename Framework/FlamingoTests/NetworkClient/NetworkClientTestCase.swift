//
//  NetworkClientTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

private struct Consts {
    static let headers = [
        (name: "Accept", value: "text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5"),
        (name: "Content-Language", value: "en, asc, ru"),
    ]
}

class NetworkClientTestCase: XCTestCase {

    func test_parametersEncodingByParametersTuple() {
        let client = NetworkDefaultClientStubs.defaultForTest()
        let params = ["1": 1, "2": 2]

        var request = RequestWithParamsTuple()
        request.parameters = params
        request.parametersEncoder = JSONParametersEncoder()

        do {
            let urlRequest = try client.urlRequest(from: request)

            guard let url = urlRequest.url else {
                XCTFail(" ")
                return
            }

            XCTAssertNotNil(urlRequest.httpBody)
            var urlRequestWithJSONParams = URLRequest(url: url)
            try request.parametersTuple?.1.encode(parameters: request.parametersTuple?.0, to: &urlRequestWithJSONParams)
            XCTAssertEqual(urlRequestWithJSONParams.httpBody, urlRequest.httpBody)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_prepareUrlRequest() {
        let client = NetworkDefaultClientStubs.defaultForTest()
        client.isUseCustomizedCustomHeaders = true
        var networkRequest = RequestWithParamsTuple()
        networkRequest.customCachePolicy = .useProtocolCachePolicy

        do {
            let request = try client.urlRequest(from: networkRequest)
            var headers = Consts.headers
            headers.append(contentsOf: NetworkDefaultClientStubs.Consts.headers)

            headers.forEach {
                name, expectedValue in

                let actualValue = request.value(forHTTPHeaderField: name)
                XCTAssertEqual(expectedValue, actualValue)
            }
            XCTAssertEqual(request.cachePolicy, networkRequest.cachePolicy)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_throwingErrorOnBadURL() {
        let expectation = self.expectation(description: #function)
        let client = NetworkDefaultClientStubs.defaultForTest()
        var networkRequest = RequestWithParamsTuple()
        networkRequest.customBaseUrl = FailURLConvertible()
        let operation = client.sendRequest(networkRequest) {
            result, _ in

            XCTAssertFalse(result.isSuccess)
            XCTAssertNotNil(result.error)

            expectation.fulfill()
        }

        XCTAssertNil(operation)

        wait(for: [expectation], timeout: 10)
    }
}

private struct RequestWithParamsTuple: NetworkRequest {
    var customURL: URLConvertible = "index.htm"
    var URL: URLConvertible {
        return customURL
    }

    var customBaseUrl: URLConvertible = "http://example.com"
    var baseURL: URLConvertible? {
        return customBaseUrl
    }

    var parameters: [String: Any]?

    var parametersEncoder: ParametersEncoder = URLParametersEncoder()

    var parametersTuple: ([String: Any], ParametersEncoder)? {
        if let parameters = parameters {
            return (parameters, parametersEncoder)
        } else {
            return nil
        }
    }

    var responseSerializer: StringResponseSerializer {
        return StringResponseSerializer()
    }

    var headers: [String: String?]? {
        return [
            Consts.headers[0].name: Consts.headers[0].value,
            Consts.headers[1].name: Consts.headers[1].value,
        ]
    }

    var customCachePolicy: URLRequest.CachePolicy?
    var cachePolicy: URLRequest.CachePolicy? {
        return customCachePolicy
    }
}

private struct FailURLConvertible: URLConvertible {
    func asURL() throws -> URL {
        throw TestURLConvertibleError.failURLConvertible
    }
}

private enum TestURLConvertibleError: Swift.Error {
    case failURLConvertible
}
