//
//  NetworkClientBaseTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

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

        return NetworkDefaultClient(configuration: configuration, session: session)
    }
}
