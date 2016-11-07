//
//  NetworkRequestMock.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 14.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

public protocol NetworkRequestMock {
    
    var responseDelay: TimeInterval { get }
    var mimeType: String { get }
    
    func responseData() -> Data?
    func responseError() -> NSError?
}

public extension NetworkRequestMock {
    
    public var responseDelay: TimeInterval {
        return 1
    }
    
    public func responseData() -> Data? {
        return nil
    }
    
    public func responseError() -> NSError? {
        return nil
    }
}
