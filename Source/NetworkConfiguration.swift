//
//  NetworkConfiguration.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkConfigurationPrototype {
    
    var baseURL: URLStringConvertible? { get }
    var debugMode: Bool { get }
    var completionQueue: dispatch_queue_t { get }
    var defaultTimeoutInterval: NSTimeInterval { get }
}

public struct NetworkConfiguration: NetworkConfigurationPrototype {
    
    public let baseURL: URLStringConvertible?
    public let debugMode: Bool
    public let completionQueue: dispatch_queue_t
    public let defaultTimeoutInterval: NSTimeInterval
    
    public init(baseURL: URLStringConvertible? = nil,
                debugMode: Bool = false,
                completionQueue: dispatch_queue_t = dispatch_get_main_queue(),
                defaultTimeoutInterval: NSTimeInterval = 60.0) {
        self.baseURL = baseURL
        self.debugMode = debugMode
        self.completionQueue = completionQueue
        self.defaultTimeoutInterval = defaultTimeoutInterval
    }
}
