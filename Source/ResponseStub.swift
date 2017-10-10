//
//  ResponseStub.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public struct ResponseStub {
    var statusCode: StatusCodes
    var headers: [String: String] // https://tools.ietf.org/html/rfc2822#section-2.2 2.2. Header Fields
    var body: Data

    init(statusCode: StatusCodes, headers: [String: String], body: Data) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    init(body: Data) {
        self.init(statusCode: .ok, headers: [:], body: body)
    }
}

extension ResponseStub: Decodable {
    enum Keys: String, CodingKey {
        case statusCode = "statusCode"
        case headers = "headers"
        case text = "text"
        case json = "json"
        case body = "body"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let statusCode: StatusCodes = (try StatusCodes(rawValue: container.decode(Int.self, forKey: .statusCode)))!
        let headers: [[String: String]] = try container.decode([[String: String]].self, forKey: .headers)
        var body: Data
        if container.contains(.text) {
            body = try container.decode(String.self, forKey: .text).data(using: .utf8)!
        } else if container.contains(.body) {
            body = try container.decode(String.self, forKey: .body).data(using: .utf8)!
        } else {
            throw Flamingo.Error.invalidRequest
        }

        self.init(statusCode: statusCode, headers: headers.first ?? [:], body: body)
    }
}
