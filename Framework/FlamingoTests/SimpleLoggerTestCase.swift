//
//  SimpleLoggerTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 11-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

class SimpleLoggerTestCase: XCTestCase {
    private struct Consts {
        static let appName = "Flamingo tests"
        static let message = "Some message"
    }

    private var logger: SimpleLogger {
        return SimpleLogger(appName: SimpleLoggerTestCase.Consts.appName)
    }

    public func test_instanciateLogger_expectedLogger() {
        let logger = self.logger

        XCTAssertNotNil(logger)
    }

    public func test_loggingMessage() {
        let logger = self.logger

        logger.log(SimpleLoggerTestCase.Consts.message)
    }

    public func test_loggingWithContext() {
        let logger = self.logger

        logger.log(SimpleLoggerTestCase.Consts.message, context: [:])
    }

    public func test_loggingWithVariableContext() {
        let logger = self.logger

        [
            ["dictionary": ["key": "value"]],
            ["array": [1, 2, 3]],
            ["number": 1],
            ["string": "string"],
            ["bool": true],
            ["object": self],
        ].forEach { context in
            logger.log(SimpleLoggerTestCase.Consts.message, context: context)
        }
    }

    public func test_loggingURLRequest() {
        let logger = self.logger
        let request = URLRequest(url: URL(string: "/")  ?? URL(fileURLWithPath: ""))

        logger.log("message", context: [ "request": request ])
    }
}
