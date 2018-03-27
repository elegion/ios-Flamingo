//
//  NetworkClientTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Flamingo

class NetworkClientTestCase: XCTestCase {

    func test_parametersEncodingByParametersTuple() {
        let client = NetworkDefaultClientStubs.defaultForTest()
        let params = ["1": 1, "2": 2]

        var request = RequestWithParamsTuple()
        request.parameters = params

        do {
            let urlRequest = try client.urlRequest(from: request)

            guard let url = urlRequest.url else {
                XCTFail(" ")
                return
            }
            
            var urlRequestWithQueryParams = URLRequest(url: url)
            try request.parametersEncoder.encode(parameters: request.parameters, to: &urlRequestWithQueryParams)
            XCTAssertNotEqual(urlRequestWithQueryParams.url, urlRequest.url)

            var urlRequestWithJSONParams = URLRequest(url: url)
            try request.parametersTuple?.1.encode(parameters: request.parametersTuple?.0, to: &urlRequestWithJSONParams)
            XCTAssertEqual(urlRequestWithJSONParams.httpBody, urlRequest.httpBody)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

private struct RequestWithParamsTuple: NetworkRequest {
    var URL: URLConvertible {
        return "index.htm"
    }

    var parameters: [String: Any]?

    var parametersEncoder: ParametersEncoder = URLParametersEncoder()

    var parametersTuple: ([String: Any], ParametersEncoder)? {
        return (["1": 1, "2": 2], JSONParametersEncoder())
    }

    var responseSerializer: StringResponseSerializer {
        return StringResponseSerializer()
    }
}
