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
    
    private let dispatchTimer: DispatchSourceTimer
    
    public init(URLRequest: Foundation.URLRequest,
                mock: NetworkRequestMock,
                dispatchQueue: DispatchQueue,
                completionQueue: DispatchQueue,
                responseSerializer: DataResponseSerializer<T>,
                completionHandler: ((T?, NSError?, NetworkContext?) -> Void)?) {
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: dispatchQueue)
        
        timer.scheduleOneshot(deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + UInt64((Double(NSEC_PER_SEC) * mock.responseDelay))))
        
        timer.setEventHandler { 
            let data = mock.responseData()
            let error = mock.responseError()
            
            let response = HTTPURLResponse(url: URLRequest.url!,
                                           mimeType: mock.mimeType,
                                           expectedContentLength: -1,
                                           textEncodingName: nil)
            
            let result = responseSerializer.serializeResponse(nil, response, data, nil)
            
            switch result {
            case .success(let value):
                if let completionHandler = completionHandler {
                    completionQueue.async {
                        completionHandler(value, error, nil)
                    }
                }
            case .failure(let error):
                if let completionHandler = completionHandler {
                    completionQueue.async {
                        completionHandler(nil, error as NSError, nil)
                    }
                }
            }
            
            timer.suspend()
        }
        
        timer.setCancelHandler { 
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
            
            if let completionHandler = completionHandler {
                completionQueue.async {
                    completionHandler(nil, error, nil)
                }
            }
        }
        
        dispatchTimer = timer
    }
    
    public func cancel() {
        dispatchTimer.cancel()
    }
    
    public func resume() {
        dispatchTimer.resume()
    }
}
