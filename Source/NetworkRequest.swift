//
//  NetworkRequest.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkRequestPrototype {
    
    var URL: URLStringConvertible { get }
    var method: Alamofire.Method { get }
    var parameters: [String : AnyObject]? { get }
    var parametersEncoding: ParameterEncoding { get }
    var baseURL: URLStringConvertible? { get }
    var headers: [String : String]? { get }
    var useCache: Bool { get }
    var mockObject: NetworkRequestMockPrototype? { get }
    var timeoutInterval: NSTimeInterval? { get }
    var completionQueue: dispatch_queue_t? { get }
}

public extension NetworkRequestPrototype {
    
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
    
    public var mockObject: NetworkRequestMockPrototype? {
        return nil
    }
    
    public var timeoutInterval: NSTimeInterval? {
        return nil
    }
    
    public var completionQueue: dispatch_queue_t? {
        return nil
    }
}

public extension NetworkRequestPrototype {
    
    public func URLRequestWithBaseURL(baseURL: URLStringConvertible? = nil,
                                      timeoutInterval: NSTimeInterval) -> NSMutableURLRequest {
        let _baseURL = self.baseURL ?? baseURL
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URL.URLString, relativeToURL: _baseURL != nil ? NSURL(string: _baseURL!.URLString) : nil)!)
        
        mutableURLRequest.timeoutInterval = self.timeoutInterval ?? timeoutInterval
        
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let headers = headers {
            for (headerName, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerName)
            }
        }
        
        let encodedMutableURLRequest = parametersEncoding.encode(mutableURLRequest, parameters: parameters).0
        
        return encodedMutableURLRequest
    }
}
