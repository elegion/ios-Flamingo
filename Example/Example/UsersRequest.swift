//
//  UsersRequest.swift
//  Example
//
//  Created by Георгий Касапиди on 12.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Flamingo

struct UsersRequest: NetworkRequest {
    
    fileprivate let useMock: Bool
    
    init(useMock: Bool = true) {
        self.useMock = useMock;
    }
    
    //MARK: - Implementation
    
    var URL: URLConvertible {
        return "users"
    }
    
    var useCache: Bool {
        return true
    }
    
    var responseSerializer: CodableJSONSerializer<[User]> {
        return CodableJSONSerializer<[User]>()
    }
}
