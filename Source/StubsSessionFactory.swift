//
//  StubsSessionFactory.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public enum StubError: Swift.Error, LocalizedError {

    public enum StubClientFactoryErrorReason: CustomStringConvertible {
        case fileNotExists(String)
        case cannotAccessToFile(String)
        case wrongFileContent
        case wrongListFormat

        public var description: String {
            switch self {
            case .fileNotExists(let string):
                return "File not exists. \(string)"
            case .cannotAccessToFile(let string):
                return "Cannot access to file. \(string)"
            case .wrongFileContent:
                return "Wrong file content"
            case .wrongListFormat:
                return "Wrong list format"
            }
        }
    }

    public enum StubClientErrorReason: CustomStringConvertible {
        case stubNotFound

        public var description: String {
            switch self {
            case .stubNotFound:
                return "Stub not found"
            }
        }
    }
    
    case stubClientFactoryError(StubClientFactoryErrorReason)
    case stubClientError(StubClientErrorReason)

    public var localizedDescription: String {
        switch self {
        case .stubClientFactoryError(let reason):
            return "Stub client factory error. \(reason)"
        case .stubClientError(let reason):
            return "Stub client error. \(reason)"
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }
}

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
}

public struct StubFile: Decodable {
    public let version: String?
    public let stubs: [RequestStubMap]

    public init(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws {
        let filemanager = FileManager()
        if !filemanager.fileExists(atPath: path) {
            throw StubError.stubClientFactoryError(.fileNotExists(path))
        }

        if !filemanager.isReadableFile(atPath: path) {
            throw StubError.stubClientFactoryError(.cannotAccessToFile(path))
        }

        guard let content = filemanager.contents(atPath: path) else {
            throw StubError.stubClientFactoryError(.wrongListFormat)
        }

        self = try decoder.decode(type(of: self), from: content)
    }
}

public class StubsSessionFactory {
    public static func session() -> StubDefaultSession {
        return StubDefaultSession()
    }

    public static func session(_ key: RequestStub, stub: ResponseStub) -> StubDefaultSession {
        let session = self.session()
        session.add(key, stub: stub)
        return session
    }

    public static func session(with stubs: [RequestStubMap]) -> StubDefaultSession {
        let session = self.session()
        session.add(stubs: stubs)

        return session
    }

    public static func session(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws -> StubDefaultSession {

        let stubFile = try StubFile(fromFile: path, decoder: decoder)

        return self.session(with: stubFile.stubs)
    }

}
