//
//  ImageRequest.swift
//  Example
//
//  Created by Георгий Касапиди on 12.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire
import Flamingo

struct ImageRequest: NetworkRequestPrototype {
    
    private let useMock: Bool
    
    init(useMock: Bool = true) {
        self.useMock = useMock;
    }
    
    // implementation
    
    var URL: URLStringConvertible {
        return "320/480?q=\(arc4random())"
    }
    
    var baseURL: URLStringConvertible? {
        return "http://lorempixel.com"
    }
    
    var mockObject: NetworkRequestMockPrototype? {
        return useMock ? ImageMock() : nil
    }
}
