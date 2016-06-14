//
//  NetworkMockOperation.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 14.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public final class NetworkMockOperation<T> {
    
    private let dispatchTimer: dispatch_source_t
    
    public init(URLRequest: NSURLRequest,
                mock: NetworkRequestMock,
                dispatchQueue: dispatch_queue_t,
                completionQueue: dispatch_queue_t,
                responseSerializer: ResponseSerializer<T, NSError>,
                completionHandler: ((T?, NSError?) -> Void)?) {
        
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue)
        
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, Int64(mock.responseDelay * Double(NSEC_PER_SEC))), DISPATCH_TIME_FOREVER, NSEC_PER_SEC / 10)
        
        dispatch_source_set_event_handler(timer) {
            let data = mock.responseData()
            let error = mock.responseError()
            
            let response = NSHTTPURLResponse(URL: URLRequest.URL!,
                                             MIMEType: mock.mimeType,
                                             expectedContentLength: -1,
                                             textEncodingName: nil)
            
            let result = responseSerializer.serializeResponse(nil, response, data, nil)
            
            switch result {
            case .Success(let value):
                if let completionHandler = completionHandler {
                    dispatch_async(completionQueue, {
                        completionHandler(value, error)
                    })
                }
            case .Failure(let error):
                if let completionHandler = completionHandler {
                    dispatch_async(completionQueue, {
                        completionHandler(nil, error)
                    })
                }
            }
            
            dispatch_suspend(timer)
        }
        
        dispatch_source_set_cancel_handler(timer) {
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
            
            if let completionHandler = completionHandler {
                dispatch_async(completionQueue, {
                    completionHandler(nil, error)
                })
            }
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
