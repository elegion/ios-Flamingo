//
//  ResponseStub.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public struct ErrorStub: Codable {
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
    
    public enum BodyType: Codable {
        case binary(Data)
        case string(String)
        case json(JSONAny)

        public init(from decoder: Decoder) throws {
            if let binary: Data = try? Data(from: decoder) {
                self = .binary(binary)
            } else if let string = try? String(from: decoder) {
                self = .string(string)
            } else {
                let json: JSONAny = try JSONAny(from: decoder)
                self = .json(json)
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .binary(let value):
                try value.encode(to: encoder)
            case .string(let value):
                try value.encode(to: encoder)
            case .json(let value):
                try value.encode(to: encoder)
            }
        }

        public var data: Data? {
            switch self {
            case .binary(let value):
                return value
            case .string(let value):
                return value.data(using: .utf8)
            case .json(let value):
                return try? JSONSerialization.data(withJSONObject: value.value, options: [])
            }
        }
    }

    public let statusCode: StatusCodes
    public let headers: [String: String]? // https://tools.ietf.org/html/rfc2822#section-2.2 2.2. Header Fields
    public let body: BodyType?
    public let error: ErrorStub?

    public init(statusCode: StatusCodes, headers: [String: String]?, body: Data?, error: ErrorStub?) {
        self.statusCode = statusCode
        self.headers = headers
        if let body = body {
            self.body = .binary(body)
        } else {
            self.body = nil
        }
        self.error = error
    }

    public init(body: Data) {
        self.init(statusCode: .ok, headers: nil, body: body, error: nil)
    }

    public init(bodyString: String) {
        self.init(statusCode: .ok, headers: nil, body: bodyString.data(using: .utf8), error: nil)
    }

    public init(bodyJSON: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        self.init(statusCode: .ok, headers: nil, body: data, error: nil)
    }
}
