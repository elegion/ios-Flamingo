//
//  MockOperation.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

public final class MockOperation {
    
    public typealias MockOperationCompletionHandler = (NSData?, NSError?) -> Void
    
    private let dispatchTimer: dispatch_source_t
    
    public init(mockObject: NetworkRequestMockPrototype, dispatchQueue: dispatch_queue_t, completionHandler: MockOperationCompletionHandler) {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue)
        
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, Int64(mockObject.responseDelay * Double(NSEC_PER_SEC))), DISPATCH_TIME_FOREVER, NSEC_PER_SEC / 10)
        
        dispatch_source_set_event_handler(timer) { 
            let responseData = mockObject.responseData()
            
            completionHandler(responseData, nil)
            
            dispatch_suspend(timer)
        }
        
        dispatch_source_set_cancel_handler(timer) { 
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
            
            completionHandler(nil, error)
        }
        
        dispatchTimer = timer
    }
    
    public func cancel() {
        dispatch_source_cancel(dispatchTimer)
    }
    
    public func resume() {
        dispatch_resume(dispatchTimer)
    }
}
