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
    typealias Body = (parameters: [String: Any], encoder: ParametersEncoder)
    
    var URL: URLConvertible { get }
    var method: HTTPMethod { get }
    var query: [String: Any]? { get }
    var body: Body? { get }
    var headers: [String: String?]? { get }
    var baseURL: URLConvertible? { get }
    var responseSerializer: ResponseSerializer { get }
    var completionQueue: DispatchQueue? { get }
    var cachePolicy: URLRequest.CachePolicy? { get }
}

public extension NetworkRequest {
    
    var method: HTTPMethod {
        return .get
    }

    var query: [String: Any]? {
        return nil
    }
    
    var body: Body? {
        return nil
    }

    var headers: [String: String?]? {
        return nil
    }
    
    var baseURL: URLConvertible? {
        return nil
    }
    
    var completionQueue: DispatchQueue? {
        return nil
    }

    var cachePolicy: URLRequest.CachePolicy? {
        return nil
    }
}

public extension NetworkRequest {
    
    var description: String {
        return """
            Request: \(String(describing: type(of: self))),
               url: \(URL) (baseurl: \(String(describing: baseURL))),
               method: \(method),
               parameters: \(body?.parameters ?? [:])),
               headers: \(String(describing: headers))
        """
    }
}
