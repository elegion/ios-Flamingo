//
//  ResponseStub.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public struct ErrorStub: Decodable {
    public let domain: String
    public let code: Int
    public let message: String?
    public var nsError: NSError? {
        var userInfo: [String: Any] = [:]
        if let message = message {
            userInfo[NSLocalizedDescriptionKey] = message
        }
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}

public struct ResponseStub: Decodable {
    public let statusCode: StatusCodes
    public let headers: [String: String] // https://tools.ietf.org/html/rfc2822#section-2.2 2.2. Header Fields
    public let body: Data?
    public let error: ErrorStub?

    public init(statusCode: StatusCodes, headers: [String: String], body: Data?, error: ErrorStub?) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.error = error
    }

    public init(body: Data) {
        self.init(statusCode: .ok, headers: [:], body: body, error: nil)
    }
}

//extension ResponseStub: Decodable {
//    enum Keys: String, CodingKey {
//        case statusCode
//        case headers
//        case body
//        case error
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Keys.self)
//        let statusCode: StatusCodes = (try StatusCodes(rawValue: container.decode(Int.self, forKey: .statusCode)))!
//        let headers: [String: String] = try container.decode(.headers)
//        let body: Data? = try container.decode(String.self, forKey: .body).data(using: .utf8)!
//        let error: ErrorStub? = try container.decode(.error)
//
//        self.init(statusCode: statusCode, headers: headers, body: body, error: error)
//    }
//}
