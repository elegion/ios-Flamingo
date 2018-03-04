//
//  RequestStub.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public struct RequestStub: Hashable {
    public let url: URL
    public let method: HTTPMethod
    public let params: [String: Any]?
    public var hashValue: Int

    init(url: URL, method: HTTPMethod, params: [String: Any]? = nil) {
        self.url = url
        self.method = method
        self.params = params
        hashValue = "\(url)\(method)\(params ?? [:])".hashValue
    }

    public static func ==(lhs: RequestStub, rhs: RequestStub) -> Bool {
        let equalParams = NSDictionary(dictionary: lhs.params ?? [:]).isEqual(to: rhs.params ?? [:])
        return lhs.url == rhs.url &&
            lhs.method == rhs.method &&
        equalParams
    }
}

public struct RequestStubMap: Decodable {
    public let url: URL
    public let method: HTTPMethod
    public let params: [String: Any]?
    public let responseStub: ResponseStub
    public var requestStub: RequestStub {
        return RequestStub(url: url, method: method, params: params)
    }

    private enum CodingKeys: String, CodingKey {
        case url
        case method
        case params
        case responseStub = "stub"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(.url)
        method = try container.decode(.method)
        if container.contains(.params),
            let paramsAsString: String = try container.decode(.params),
            let paramsAsData = paramsAsString.data(using: .utf8) {
            params = try JSONSerialization.jsonObject(with: paramsAsData, options: .allowFragments) as? [String: Any]
        } else {
            params = nil
        }
        responseStub = try container.decode(.responseStub)
    }

    public init(url: URL, method: HTTPMethod, params: [String: Any]?, responseStub: ResponseStub) {
        self.url = url
        self.method = method
        self.params = params
        self.responseStub = responseStub
    }

    public init(request: RequestStub, responseStub: ResponseStub) {
        self.url = request.url
        self.method = request.method
        self.params = request.params
        self.responseStub = responseStub
    }
}
