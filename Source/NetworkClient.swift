//
//  NetworkClient.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkClientPrototype: class {
    
    func executeCommand<T>(networkCommand: NetworkCommand<T>, useCache: Bool, mockObject: NetworkRequestMockPrototype?) -> CancelableOperation
}

public class NetworkClient: NetworkClientPrototype {
    
    private static let operationQueue = dispatch_queue_create("com.flamingo.operation-queue", DISPATCH_QUEUE_CONCURRENT)
    
    private let configuration: NetworkConfigurationPrototype
    private let cacheManager: NetworkCacheManagerPrototype?
    private let networkManager: Manager
    
    public init(configuration: NetworkConfigurationPrototype,
                cacheManager: NetworkCacheManagerPrototype? = nil,
                networkManager: Manager = Manager.sharedInstance) {
        self.configuration = configuration
        self.cacheManager = cacheManager
        self.networkManager = networkManager
    }
    
    public func executeCommand<T>(networkCommand: NetworkCommand<T>, useCache: Bool, mockObject: NetworkRequestMockPrototype?) -> CancelableOperation {
        let URLRequest = networkCommand.requestInfo.URLRequestWithBaseURL(configuration.baseURL, timeoutInterval: configuration.defaultTimeoutInterval)
        
        let _completionQueue = networkCommand.requestInfo.completionQueue ?? self.configuration.completionQueue
        
        if let mockObject = mockObject {
            let mockOperation = MockOperation(mockObject: mockObject, dispatchQueue: NetworkClient.operationQueue) { (data, error) in
                guard error == nil else {
                    dispatch_async(_completionQueue, {
                        networkCommand.responseHandler(nil, error)
                    })
                    
                    return
                }
                
                let response = NSHTTPURLResponse(URL: URLRequest.URL!, MIMEType: mockObject.mimeType, expectedContentLength: -1, textEncodingName: nil)
                
                let result = networkCommand.responseSerializer.serializeResponse(nil, response, data, nil)
                
                switch result {
                case .Success(let value):
                    dispatch_async(_completionQueue, {
                        networkCommand.responseHandler(value, nil)
                    })
                case .Failure(let error):
                    dispatch_async(_completionQueue, {
                        networkCommand.responseHandler(nil, error)
                    })
                }
            }
            
            mockOperation.resume()
            
            return mockOperation
        }
        
        let _useCache = useCache && self.cacheManager != nil
        
        let request = networkManager.request(URLRequest).response(queue: _completionQueue) { (request, response, data, error) in
            var _data: NSData? = data
            
            if _useCache && self.shouldUseCachedResponseDataIfError(error) {
                dispatch_sync(NetworkClient.operationQueue, {
                    _data = self.cacheManager!.responseDataForRequest(URLRequest)
                })
            }
            
            dispatch_async(NetworkClient.operationQueue, {
                let result = networkCommand.responseSerializer.serializeResponse(request, response, _data, nil)
                
                switch result {
                case .Success(let value):
                    if _useCache {
                        self.cacheManager!.setResponseData(_data!, forRequest: URLRequest)
                    }
                    
                    dispatch_async(_completionQueue, {
                        networkCommand.responseHandler(value, error)
                    })
                case .Failure(let error):
                    dispatch_async(_completionQueue, {
                        networkCommand.responseHandler(nil, error)
                    })
                }
            })
        }
        
        if configuration.debugMode {
            debugPrint(request)
        }
        
        if !networkManager.startRequestsImmediately {
            request.resume()
        }
        
        return request
    }
    
    private func shouldUseCachedResponseDataIfError(error: NSError?) -> Bool {
        guard let error = error else {
            return false
        }
        
        if error.domain != NSURLErrorDomain {
            return false
        }
        
        switch error.code {
        case NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorDNSLookupFailed,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorCallIsActive,
             NSURLErrorDataNotAllowed:
            return true
        default:
            let underlyingError = (error.userInfo as! [String : AnyObject])[NSUnderlyingErrorKey] as? NSError
            
            return shouldUseCachedResponseDataIfError(underlyingError)
        }
    }
}
