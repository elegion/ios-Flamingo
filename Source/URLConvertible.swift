//
//  URLConvertible.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/11/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case put = "PUT"
    case head = "HEAD"
    case options = "OPTIONS"
    case update = "UPDATE"
    
}

enum URLConvertableError: Swift.Error {
    
    case stringToURLConversionError
    
}

public protocol URLConvertible {
    
    func asURL() throws -> URL
    
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        guard let resultURL = URL(string: self) else {
            throw URLConvertableError.stringToURLConversionError
        }
        
        return resultURL
    }
}

extension URL: URLConvertible {
    public func asURL() throws -> URL {
        return self
    }
}
