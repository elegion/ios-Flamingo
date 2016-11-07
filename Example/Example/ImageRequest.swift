//
//  ImageRequest.swift
//  Example
//
//  Created by Георгий Касапиди on 12.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import Flamingo

struct ImageRequest: NetworkRequest {
    
    fileprivate let useMock: Bool
    
    init(useMock: Bool = true) {
        self.useMock = useMock;
    }
    
    // implementation
    
    var URL: URLConvertible {
        return "320/480?q=\(arc4random())"
    }
    
    var baseURL: URLConvertible? {
        return "http://lorempixel.com"
    }
    
    var responseSerializer: DataResponseSerializer<Image> {
        return DataRequest.imageResponseSerializer()
    }
    
    var mockObject: NetworkRequestMock? {
        return useMock ? ImageMock() : nil
    }
}
