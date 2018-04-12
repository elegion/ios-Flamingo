//
//  StubsManager.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public typealias Stubs = [RequestStub: ResponseStub]

public enum NotFoundStubBehavior {
    case useRealClient
    case giveError
}

public protocol StubsManager: NetworkClientMutater {
    func add(_ key: RequestStub, stub: ResponseStub)
    func add(stubs: Stubs)
    func remove(_ key: RequestStub)
    func hasStub(_ key: RequestStub) -> Bool
}

public class StubsDefaultManager: StubsManager {

    public var notFoundStubBehavior: NotFoundStubBehavior = .giveError

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
        if let key = RequestStub(request),
            let stub = stubs[key] {
            return stub.rawResponseTuple(url: key.url)
        }

        switch notFoundStubBehavior {
        case .giveError:
            let response = HTTPURLResponse(
                url: URL(fileURLWithPath: ""),
                statusCode: 23,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            return (nil, response, StubsError.fakeResponse)
        case .useRealClient:
            return nil
        }
    }
}

extension ResponseStub {
    func rawResponseTuple(url: URL) -> NetworkClientMutater.RawResponseTuple {
        let stubData = body?.data

        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode.rawValue,
            httpVersion: nil,
            headerFields: headers
        )

        return (stubData, response, error?.nsError)
    }
}
