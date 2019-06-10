//
//  Cancelable.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol Cancellable {
    
    func cancel()
}

extension URLSessionDataTask: Cancellable {
        
}

class EmptyCancellable: Cancellable {
    
    func cancel() {
        // do nothing
    }
    
}
