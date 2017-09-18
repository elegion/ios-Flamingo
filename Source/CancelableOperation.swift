//
//  CancelableOperation.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol CancelableOperation {
    
    func cancelOperation()
}

extension URLSessionDataTask: CancelableOperation {
    
    public func cancelOperation() {
        cancel()
    }
    
}
