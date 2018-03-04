//
//  StubsSessionFactory.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

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
    public static func session() -> StubsDefaultSession {
        return StubsDefaultSession()
    }

    public static func session(_ key: RequestStub, stub: ResponseStub) -> StubsDefaultSession {
        let session = self.session()
        session.add(key, stub: stub)
        return session
    }

    public static func session(with stubs: [RequestStubMap]) -> StubsDefaultSession {
        let session = self.session()
        session.add(stubsArray: stubs)

        return session
    }

    public static func session(fromFile path: String, decoder: JSONDecoder = JSONDecoder()) throws -> StubsDefaultSession {

        let stubFile = try StubFile(fromFile: path, decoder: decoder)

        return self.session(with: stubFile.stubs)
    }
}
