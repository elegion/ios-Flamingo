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
    
    var URL: URLConvertible { get }
    var method: HTTPMethod { get }
    var parameters: [String : AnyObject]? { get }
    var parametersEncoding: ParameterEncoding { get }
    var baseURL: URLConvertible? { get }
    var headers: [String : String]? { get }
    var useCache: Bool { get }
    var responseSerializer: DataResponseSerializer<T> { get }
    var mockObject: NetworkRequestMock? { get }
    var timeoutInterval: TimeInterval? { get }
    var completionQueue: DispatchQueue? { get }
}

public extension NetworkRequest {
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var parameters: [String : AnyObject]? {
        return nil
    }
    
    public var parametersEncoding: ParameterEncoding {
        return URLEncoding()
    }
    
    public var baseURL: URLConvertible? {
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
    
    public var timeoutInterval: TimeInterval? {
        return nil
    }
    
    public var completionQueue: DispatchQueue? {
        return nil
    }
}
