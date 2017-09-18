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
