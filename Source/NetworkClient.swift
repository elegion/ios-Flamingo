//
//  NetworkClient.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkClient: class {
    
    func sendRequest<T: NetworkRequest>(networkRequest: T, completionHandler: ((T.T?, NSError?, NetworkContext?) -> Void)?) -> CancelableOperation
}

public class NetworkDefaultClient: NetworkClient {
    
    private static let operationQueue = dispatch_queue_create("com.flamingo.operation-queue", DISPATCH_QUEUE_CONCURRENT)
    
    private let configuration: NetworkConfiguration
    private let offlineCacheManager: NetworkOfflineCacheManager?
    
    public let networkManager: Manager
    
    public init(configuration: NetworkConfiguration,
                offlineCacheManager: NetworkOfflineCacheManager? = nil,
                networkManager: Manager = Manager.sharedInstance) {
        
        self.configuration = configuration
        self.offlineCacheManager = offlineCacheManager
        self.networkManager = networkManager
    }
    
    public func sendRequest<T : NetworkRequest>(networkRequest: T, completionHandler: ((T.T?, NSError?, NetworkContext?) -> Void)?) -> CancelableOperation {
        let URLRequest = mutableURLRequestFromNetworkRequest(networkRequest)
        
        let _completionQueue = networkRequest.completionQueue ?? self.configuration.completionQueue
        
        if configuration.useMocks {
            if let mock = networkRequest.mockObject {
                let mockOperation = NetworkMockOperation(URLRequest: URLRequest,
                                                         mock: mock,
                                                         dispatchQueue: NetworkDefaultClient.operationQueue,
                                                         completionQueue: _completionQueue,
                                                         responseSerializer: networkRequest.responseSerializer,
                                                         completionHandler: completionHandler)
                
                mockOperation.resume()
                
                return mockOperation
            }
        }
        
        let _useCache = networkRequest.useCache && self.offlineCacheManager != nil
        
        let _request = networkManager.request(URLRequest).validate().response(queue: _completionQueue) { (request, response, data, error) in
            
            let context = NetworkContext(request: request, response: response, data: data, error: error)
            
            var _data: NSData? = data
            
            if _useCache && self.shouldUseCachedResponseDataIfError(error) {
                dispatch_sync(NetworkDefaultClient.operationQueue, {
                    _data = self.offlineCacheManager!.responseDataForRequest(URLRequest)
                })
            }
            
            dispatch_async(NetworkDefaultClient.operationQueue, {
                let result = networkRequest.responseSerializer.serializeResponse(request, response, _data, nil)
                
                switch result {
                case .Success(let value):
                    if _useCache {
                        self.offlineCacheManager!.setResponseData(_data!, forRequest: URLRequest)
                    }
                    
                    if let completionHandler = completionHandler {
                        dispatch_async(_completionQueue, {
                            completionHandler(value, error, context)
                        })
                    }
                case .Failure(let _error):
                    if let completionHandler = completionHandler {
                        dispatch_async(_completionQueue, {
                            completionHandler(nil, _error, context)
                        })
                    }
                }
            })
        }
        
        if configuration.debugMode {
            debugPrint(_request)
        }
        
        if !networkManager.startRequestsImmediately {
            _request.resume()
        }
        
        return _request
    }
    
    public func mutableURLRequestFromNetworkRequest<T : NetworkRequest>(networkRequest: T) -> NSMutableURLRequest {
        let _baseURL = networkRequest.baseURL ?? configuration.baseURL
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: networkRequest.URL.URLString, relativeToURL: _baseURL != nil ? NSURL(string: _baseURL!.URLString) : nil)!)
        
        mutableURLRequest.timeoutInterval = networkRequest.timeoutInterval ?? configuration.defaultTimeoutInterval
        
        mutableURLRequest.HTTPMethod = networkRequest.method.rawValue
        
        if let headers = networkRequest.headers {
            for (headerName, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerName)
            }
        }
        
        if let customHeaders = customHeadersForRequest(networkRequest) {
            for (headerName, headerValue) in customHeaders {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerName)
            }
        }
        
        let encodedMutableURLRequest = networkRequest.parametersEncoding.encode(mutableURLRequest, parameters: networkRequest.parameters).0
        
        return encodedMutableURLRequest
    }
    
    public func customHeadersForRequest<T : NetworkRequest>(networkRequest: T) -> [String : String]? {
        return nil
    }
    
    public func shouldUseCachedResponseDataIfError(error: NSError?) -> Bool {
        if let error = error {
            return error.isNetworkConnectionError
        }
        
        return false
    }
}
