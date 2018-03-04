//
//  StubsSession.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public typealias Stubs = [RequestStub: ResponseStub]

public protocol StubsSession: NetworkClientMutater {
    func add(_ key: RequestStub, stub: ResponseStub)
    func add(stubs: Stubs)
    func remove(_ key: RequestStub)
    func hasStub(_ key: RequestStub) -> Bool
}

private class StubTask: CancelableOperation {
    public func cancelOperation() {}
}

public class StubsDefaultSession: StubsSession {

    private var stubs: Stubs = [:]

    public init() {
        
    }

    public func add(_ key: RequestStub, stub: ResponseStub) {
        stubs[key] = stub
    }

    public func add(stubs: Stubs) {
        self.stubs.merge(stubs, uniquingKeysWith: { $1 })
    }

    public func remove(_ key: RequestStub) {
        stubs.removeValue(forKey: key)
    }

    public func hasStub(_ key: RequestStub) -> Bool {
        return stubs[key] != nil
    }

    public func add(stubsArray: [RequestStubMap]) {
        for i in stubsArray.indices {
            self.stubs[stubsArray[i].requestStub] = stubsArray[i].responseStub
        }
    }

    // MARK: - NetworkClientMutater

    public func response<Request>(for request: Request) -> NetworkClientMutater.RawResponseTuple? where Request: NetworkRequest {
        if let key = requestAsRequestStub(request),
            let stub = stubs[key] {
            return stub.rawResponseTuple(url: key.url)
        }

        return nil
    }
}

extension ResponseStub {
    func rawResponseTuple(url: URL) -> NetworkClientMutater.RawResponseTuple {
        let stubData = body

        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode.rawValue,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )

        return (stubData, response, error?.nsError)
    }
}

internal func requestAsRequestStub<Request>(_ request: Request) -> RequestStub? where Request: NetworkRequest {
    let requestURL = (try? request.URL.asURL()) ?? URL(fileURLWithPath: "")
    return RequestStub(url: requestURL, method: request.method, params: request.parameters)
}
