////
////  NetworkClientBaseTestCase.swift
////  FlamingoTests
////
////  Created by Dmitrii Istratov on 05-10-2017.
////  Copyright © 2017 ELN. All rights reserved.
////
//
import Flamingo

public protocol StubbableClient: class {
    var stubsSession: StubsSession? { get set }

    func enableStubs()
    func disableStubs()
}

final class NetworkDefaultClientStubs: NetworkDefaultClient, StubbableClient {
    var stubsSession: StubsSession?

    func enableStubs() {
        if let stubsSession = stubsSession {
            addMutater(stubsSession)
        }
    }

    func disableStubs() {
        if let stubsSession = stubsSession {
            removeMutater(stubsSession)
        }
    }
}

extension NetworkDefaultClientStubs {
    static func defaultForTest() -> NetworkDefaultClientStubs {
        let configuration = NetworkDefaultConfiguration(baseURL: "http://example.com/", parallel: false)
        return NetworkDefaultClientStubs(configuration: configuration, session: .shared)
    }
}
