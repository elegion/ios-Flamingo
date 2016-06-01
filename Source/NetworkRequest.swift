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
    var parametersEncoding: ParameterEncoding { get }
    var parameters: [String : AnyObject]? { get }
    var headers: [String : String]? { get }
    var timeoutInterval: NSTimeInterval? { get }
    var completionQueue: dispatch_queue_t? { get }
}

public struct NetworkRequest: NetworkRequestPrototype {
    
    public let URL: URLStringConvertible
    public let method: Alamofire.Method
    public let parametersEncoding: ParameterEncoding
    public let parameters: [String : AnyObject]?
    public let headers: [String : String]?
    public let timeoutInterval: NSTimeInterval?
    public let completionQueue: dispatch_queue_t?
    
    public init(URL: URLStringConvertible,
                method: Alamofire.Method = .GET,
                parametersEncoding: ParameterEncoding = .URL,
                parameters: [String : AnyObject]? = nil,
                headers: [String : String]? = nil,
                timeoutInterval: NSTimeInterval? = nil,
                completionQueue: dispatch_queue_t? = nil) {
        self.URL = URL
        self.method = method
        self.parametersEncoding = parametersEncoding
        self.parameters = parameters
        self.headers = headers
        self.timeoutInterval = timeoutInterval
        self.completionQueue = completionQueue
    }
}

public extension NetworkRequestPrototype {
    
    public func URLRequestWithBaseURL(baseURL: URLStringConvertible? = nil,
                                      timeoutInterval: NSTimeInterval) -> NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URL.URLString, relativeToURL: baseURL != nil ? NSURL(string: baseURL!.URLString) : nil)!)
        
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
