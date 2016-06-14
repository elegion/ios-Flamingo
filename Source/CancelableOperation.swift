//
//  CancelableOperation.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol CancelableOperation {
    
    func cancelOperation()
}

extension Request: CancelableOperation {
    
    public func cancelOperation() {
        cancel()
    }
}

extension NetworkMockOperation: CancelableOperation {
    
    public func cancelOperation() {
        cancel()
    }
}
