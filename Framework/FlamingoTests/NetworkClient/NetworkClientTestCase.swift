//
//  NetworkClientTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class NetworkClientTestCase: XCTestCase {

    public func test_instanciateClient_expectedClient() {
        let client = NetworkDefaultClientStubs.defaultForTest()

        XCTAssertNotNil(client)
    }
}
