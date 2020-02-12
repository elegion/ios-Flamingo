//
//  StubsManagerFactory.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public enum JSONAny: Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case array([JSONAny])
    case dictionary([String: JSONAny])
    case null

    public init(from decoder: Decoder) throws {
        if let bool = try? Bool(from: decoder) {
            self = .bool(bool)
        } else if let integer = try? Int(from: decoder) {
            self = .int(integer)
        } else if let double = try? Double(from: decoder) {
            self = .double(double)
        } else if let string = try? String(from: decoder) {
            self = .string(string)
        } else if let array = try? [JSONAny](from: decoder) {
            self = .array(array)
        } else if let dictionary = try? [String: JSONAny](from: decoder) {
            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .int(let value):
            try value.encode(to: encoder)
        case .double(let value):
            try value.encode(to: encoder)
        case .string(let value):
            try value.encode(to: encoder)
        case .bool(let value):
            try value.encode(to: encoder)
        case .array(let value):
            try value.encode(to: encoder)
        case .dictionary(let value):
            try value.encode(to: encoder)
        case .null:
            //TODO
            break
        }
    }

    public var value: Any {
        switch self {
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .string(let value):
            return value
        case .bool(let value):
            return value
        case .array(let value):
            return value.map({ $0.value })
        case .dictionary(let value):
            return value.mapValues({ $0.value })
        case .null:
            return NSNull()
        }
    }
}

public struct RequestStubMap: Decodable {

    public let url: URL
    public let method: HTTPMethod
    public let query: [String: Any]?
    public let body: [String: Any]?
    
    public let responseStub: ResponseStub
    
    public var requestStub: RequestStub {
        return RequestStub(url: url, method: method, query: query, body: body)
    }

    private enum CodingKeys: String, CodingKey {
        case url
        case method
        case query
        case body
        case responseStub = "stub"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(.url)
        method = try container.decode(.method)
        
        if container.contains(.query) {
            let jsonQuery: JSONAny = try container.decode(.query)
            query = jsonQuery.value as? [String: Any]
        } else {
            query = nil
        }
        
        if container.contains(.body) {
            let jsonBody: JSONAny = try container.decode(.body)
            body = jsonBody.value as? [String: Any]
        } else {
            body = nil
        }
        
        responseStub = try container.decode(.responseStub)
    }

    public init(url: URL, method: HTTPMethod, query: [String: Any]?, body: [String: Any]?, responseStub: ResponseStub) {
        self.url = url
        self.method = method
        self.query = query
        self.body = body
        self.responseStub = responseStub
    }

    public init(request: RequestStub, responseStub: ResponseStub) {
        self.url = request.url
        self.method = request.method
        self.query = request.query
        self.body = request.body
        self.responseStub = responseStub
    }
}

public struct StubFile: Decodable {
    
    public let version: String?
    public let stubs: [RequestStubMap]

    public init(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws {
        let filemanager = FileManager.default
        
        guard filemanager.fileExists(atPath: path) else {
            throw StubsError.stubClientFactoryError(.fileNotExists(path))
        }

        guard filemanager.isReadableFile(atPath: path) else {
            throw StubsError.stubClientFactoryError(.cannotAccessToFile(path))
        }

        guard let content = filemanager.contents(atPath: path) else {
            throw StubsError.stubClientFactoryError(.wrongListFormat)
        }

        self = try decoder.decode(type(of: self), from: content)
    }
}

public class StubsManagerFactory {
    
    public static func manager() -> StubsDefaultManager {
        return StubsDefaultManager()
    }

    public static func manager(_ key: RequestStub, stub: ResponseStub) -> StubsDefaultManager {
        let session = manager()
        session.add(key, stub: stub)
        return session
    }

    public static func manager(with stubs: [RequestStubMap]) -> StubsDefaultManager {
        let session = manager()
        session.add(stubsArray: stubs)

        return session
    }

    public static func manager(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws -> StubsDefaultManager {
        let stubFile = try StubFile(fromFile: path, decoder: decoder)

        return manager(with: stubFile.stubs)
    }
}
