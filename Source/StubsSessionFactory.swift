//
//  StubsSessionFactory.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

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
