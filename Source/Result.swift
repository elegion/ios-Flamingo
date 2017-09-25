//
//  Result.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public enum Result<Value> {
    
    case success(Value)
    case error(Swift.Error)
    
}

public extension Result {
    
    public var value: Value? {
        switch self {
        case .success(let result):
            return result
        case .error:
            return nil
        }
    }
    
    public var error: Swift.Error? {
        switch self {
        case .success:
            return nil
        case .error(let result):
            return result
        }
    }
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }
    
}
