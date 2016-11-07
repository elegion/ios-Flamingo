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
    
    var baseURL: URLConvertible? { get }
    var useMocks: Bool { get }
    var debugMode: Bool { get }
    var completionQueue: DispatchQueue { get }
    var defaultTimeoutInterval: TimeInterval { get }
}

public struct NetworkDefaultConfiguration: NetworkConfiguration {
    
    public let baseURL: URLConvertible?
    public let useMocks: Bool
    public let debugMode: Bool
    public let completionQueue: DispatchQueue
    public let defaultTimeoutInterval: TimeInterval
    
    public init(baseURL: URLConvertible? = nil,
                useMocks: Bool = false,
                debugMode: Bool = false,
                completionQueue: DispatchQueue = DispatchQueue.main,
                defaultTimeoutInterval: TimeInterval = 60.0) {
        
        self.baseURL = baseURL
        self.useMocks = useMocks
        self.debugMode = debugMode
        self.completionQueue = completionQueue
        self.defaultTimeoutInterval = defaultTimeoutInterval
    }
}
