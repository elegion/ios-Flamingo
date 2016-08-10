//
//  NetworkRequest.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 14.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkRequest {
    
    associatedtype T
    
    var URL: URLStringConvertible { get }
    var method: Alamofire.Method { get }
    var parameters: [String : AnyObject]? { get }
    var parametersEncoding: ParameterEncoding { get }
    var baseURL: URLStringConvertible? { get }
    var headers: [String : String]? { get }
    var useCache: Bool { get }
    var responseSerializer: ResponseSerializer<T, NSError> { get }
    var mockObject: NetworkRequestMock? { get }
    var timeoutInterval: NSTimeInterval? { get }
    var completionQueue: dispatch_queue_t? { get }
}

public extension NetworkRequest {
    
    public var method: Alamofire.Method {
        return .GET
    }
    
    public var parameters: [String : AnyObject]? {
        return nil
    }
    
    public var parametersEncoding: ParameterEncoding {
        return .URL
    }
    
    public var baseURL: URLStringConvertible? {
        return nil
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var useCache: Bool {
        return false
    }
    
    public var mockObject: NetworkRequestMock? {
        return nil
    }
    
    public var timeoutInterval: NSTimeInterval? {
        return nil
    }
    
    public var completionQueue: dispatch_queue_t? {
        return nil
    }
}
