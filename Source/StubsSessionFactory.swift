//
//  StubsSessionFactory.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

private struct StubFile: Decodable {
    var version: String?
    var stubs: [Stub]
}

public struct Stub: Decodable {
    var url: String
    var method: HTTPMethod
    var stub: ResponseStub
}

public class StubsSessionFactory {
    public static func session() -> StubDefaultSession {
        return StubDefaultSession()
    }

    public static func session(url: String, method: HTTPMethod, stub: ResponseStub) -> StubDefaultSession {
        return self.session().add(url, method: method, stub: stub)
    }

    public static func session(with stubs: [Stub]) -> StubDefaultSession {
        let client = self.session()
        stubs.forEach { _ = client.add($0.url, method: $0.method, stub: $0.stub) }

        return client
    }

    public static func session(fromFile path: String) throws -> StubDefaultSession {
        let filemanager = FileManager()
        if !filemanager.fileExists(atPath: path) {
            throw Error.stubClientFactoryError(.fileNotExists(path))
        }

        if !filemanager.isReadableFile(atPath: path) {
            throw Error.stubClientFactoryError(.cannotAccessToFile(path))
        }

        let content = filemanager.contents(atPath: path)

        let serializer = JSONSerializer()
        let deserializedStubsResult: Result<StubFile> = serializer.deserialize(data: content!)
        guard let stubs = deserializedStubsResult.value else {
            throw Error.stubClientFactoryError(.wrongListFormat)
        }

        return self.session(with: stubs.stubs)
    }

}
