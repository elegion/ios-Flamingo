//
//  UsersRequest.swift
//  Example
//
//  Created by Георгий Касапиди on 12.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire
import Flamingo

struct UsersRequest: NetworkRequest {
    
    private let useMock: Bool
    
    init(useMock: Bool = true) {
        self.useMock = useMock;
    }
    
    // implementation
    
    var URL: URLStringConvertible {
        return "users"
    }
    
    var useCache: Bool {
        return true
    }
    
    var responseSerializer: ResponseSerializer<[User], NSError> {
        return ResponseSerializer<User, NSError>.arrayResponseSerializer()
    }
    
    var mockObject: NetworkRequestMock? {
        return useMock ? UsersMock() : nil
    }
}
