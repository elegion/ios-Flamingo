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
import ObjectMapper

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
    
    var responseSerializer: DataResponseSerializer<[User]> {
        let wrapper = ObjectMapperWrapper(ObjectMapper.Mapper<User>())
        return DataResponseSerializer<User>.arrayResponseSerializer(mapper: wrapper)
    }
    
    var mockObject: NetworkRequestMock? {
        return useMock ? UsersMock() : nil
    }
}
