//
//  NetworkClientBaseTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

public protocol StubbableClient: class {
    var stubs: StubsSession? { get set }
    var stubsErrorBehavior: StubsErrorBehavior { get set }

    func enableStubs()
    func disableStubs()
}

public enum StubsErrorBehavior {
    case useRealClient
    case returnError
}

final class NetworkDefaultClientStubs: NetworkDefaultClient, StubbableClient {
    var stubs: StubsSession?

    var stubsErrorBehavior: StubsErrorBehavior = .returnError

    func enableStubs() {

    }

    func disableStubs() {

    }
}

class NetworkClientBaseTestCase: XCTestCase {
    internal var configuration: NetworkConfiguration {
        return NetworkDefaultConfiguration(baseURL: "http://example.com/")
    }

    internal var session: URLSession {
        return .shared
    }

    internal var client: NetworkClient & StubbableClient {
        let configuration = self.configuration
        let session = self.session

        return NetworkDefaultClientStubs(configuration: configuration, session: session)
    }
}
