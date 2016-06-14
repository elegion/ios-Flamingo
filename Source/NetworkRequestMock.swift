//
//  NetworkRequestMock.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 14.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

public protocol NetworkRequestMock {
    
    var responseDelay: NSTimeInterval { get }
    var mimeType: String { get }
    
    func responseData() -> NSData?
    func responseError() -> NSError?
}

public extension NetworkRequestMock {
    
    public var responseDelay: NSTimeInterval {
        return 1
    }
    
    public func responseData() -> NSData? {
        return nil
    }
    
    public func responseError() -> NSError? {
        return nil
    }
}
