//
//  StubsManagerFactory.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

private enum JSONAny: Decodable {
    case int(Int)
    case string(String)
    case bool(Bool)
    case array([JSONAny])
    case dictionary([String: JSONAny])
    case null

    init(from decoder: Decoder) throws {
        if let integer = try? Int(from: decoder) {
            self = .int(integer)
        } else if let string = try? String(from: decoder) {
            self = .string(string)
        } else if let bool = try? Bool(from: decoder) {
            self = .bool(bool)
        } else if let array = try? [JSONAny](from: decoder) {
            self = .array(array)
        } else if let dictionary = try? [String: JSONAny](from: decoder) {
            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }

    var value: Any {
        switch self {
        case .int(let value):
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

private extension Dictionary where Key == String, Value == JSONAny {
    var simpleDictionary: [String: Any] {
        return self.mapValues({ $0.value })
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
        if container.contains(.params) {
            let jsonParams: [String: JSONAny] = try container.decode(.params)
            params = jsonParams.simpleDictionary
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

public struct StubFile: Decodable {
    public let version: String?
    public let stubs: [RequestStubMap]

    public init(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws {
        let filemanager = FileManager.default
        if !filemanager.fileExists(atPath: path) {
            throw StubsError.stubClientFactoryError(.fileNotExists(path))
        }

        if !filemanager.isReadableFile(atPath: path) {
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
        let session = self.manager()
        session.add(key, stub: stub)
        return session
    }

    public static func manager(with stubs: [RequestStubMap]) -> StubsDefaultManager {
        let session = self.manager()
        session.add(stubsArray: stubs)

        return session
    }

    public static func manager(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws -> StubsDefaultManager {

        let stubFile = try StubFile(fromFile: path, decoder: decoder)

        return self.manager(with: stubFile.stubs)
    }
}
