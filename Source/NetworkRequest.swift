//
//  NetworkRequest.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/11/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol NetworkRequest: CustomStringConvertible {
    
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

public extension NetworkRequest {
    var description: String {
        return """
            Request: \(String(describing: type(of: self))),
               url: \(self.URL) (baseurl: \(String(describing: self.baseURL))),
               method: \(self.method),
               parameters: \(String(describing: self.parameters)),
               headers: \(String(describing: self.headers))
        
        """
    }
}
