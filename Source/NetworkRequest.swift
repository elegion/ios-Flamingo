//
//  NetworkRequest.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/11/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol NetworkRequest {
    
    associatedtype ResponseSerializer: ResponseSerialization
    typealias Response = ResponseSerializer.Serialized
    
    var URL: URLConvertible { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var parametersEncoder: ParametersEncoder { get }
    var headers: [String: String?]? { get }
    var baseURL: URLConvertible? { get }
    var responseSerializer: ResponseSerializer { get }
    var completionQueue: DispatchQueue? { get }
}

public extension NetworkRequest {
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var parametersEncoder: ParametersEncoder {
        return URLParametersEncoder()
    }
    
    var headers: [String: String?]? {
        return nil
    }
    
    var baseURL: URLConvertible? {
        return nil
    }
    
    var completionQueue: DispatchQueue? {
        return .main
    }
    
}
