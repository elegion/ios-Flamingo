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
}

private struct RequestWithParamsTuple: NetworkRequest {
    var URL: URLConvertible {
        return "index.htm"
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
}
