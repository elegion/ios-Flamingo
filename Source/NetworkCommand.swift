//
//  NetworkCommand.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkCommandPrototype {
    
    associatedtype T
    
    var requestInfo: NetworkRequestPrototype { get }
    var responseSerializer: ResponseSerializer<T, NSError> { get }
    var responseHandler: (T?, NSError?) -> Void { get }
}

public struct NetworkCommand<T>: NetworkCommandPrototype {
    
    public let requestInfo: NetworkRequestPrototype
    public let responseSerializer: ResponseSerializer<T, NSError>
    public let responseHandler: (T?, NSError?) -> Void
    
    public init(requestInfo: NetworkRequestPrototype,
                responseSerializer: ResponseSerializer<T, NSError>,
                responseHandler: (T?, NSError?) -> Void) {
        self.requestInfo = requestInfo
        self.responseSerializer = responseSerializer
        self.responseHandler = responseHandler
    }
}
