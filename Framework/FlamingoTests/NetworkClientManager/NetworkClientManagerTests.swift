//
//  NetworkClientManagerTests.swift
//  FlamingoTests
//
//  Created by Andrey Nazarov on 24/12/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import XCTest
import Foundation
@testable import Flamingo

//swiftlint:disable trailing_whitespace

class NetworkClientManagerTests: XCTestCase {
    var basicClient: NetworkDefaultClient = {
        let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/")
        return NetworkDefaultClient(configuration: configuration, session: .shared)
    }()
    
    var basicLogger: Logger = {
        return BasicLogger()
    }()
    
    func test_basicTest() {
        let expectations = expectation(description: #function)
        
        let request = UsersRequest()
        basicClient.sendRequest(request) { (response, _) in
            
            self.basicLogger.log("Testing Manager", context: ["Response": response.value?.first])
            
            expectations.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

struct UsersRequest: NetworkRequest {
    var responseSerializer: CodableJSONSerializer<[UserTestModel]> {
        return CodableJSONSerializer()
    }
    
    typealias ResponseSerializer = CodableJSONSerializer<[UserTestModel]>
    
    var URL: URLConvertible {
        return "users"
    }
    
}

struct UserTestModel: Decodable {
    let username: String
    let name: String
}

struct BasicLogger: Logger {
    
    func log(_ message: String, context: [String: Any?]?) {
        print(String(format: "Message: %@, Context: %@", message, context ?? []))
    }
    
}

//swiftlint:enable trailing_whitespace
