//
//  NetworkConfiguration.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkConfiguration {
    
    var baseURL: URLStringConvertible? { get }
    var useMocks: Bool { get }
    var debugMode: Bool { get }
    var completionQueue: dispatch_queue_t { get }
    var defaultTimeoutInterval: NSTimeInterval { get }
}

public struct NetworkDefaultConfiguration: NetworkConfiguration {
    
    public let baseURL: URLStringConvertible?
    public let useMocks: Bool
    public let debugMode: Bool
    public let completionQueue: dispatch_queue_t
    public let defaultTimeoutInterval: NSTimeInterval
    
    public init(baseURL: URLStringConvertible? = nil,
                useMocks: Bool = true,
                debugMode: Bool = false,
                completionQueue: dispatch_queue_t = dispatch_get_main_queue(),
                defaultTimeoutInterval: NSTimeInterval = 60.0) {
        
        self.baseURL = baseURL
        self.useMocks = useMocks
        self.debugMode = debugMode
        self.completionQueue = completionQueue
        self.defaultTimeoutInterval = defaultTimeoutInterval
    }
}
