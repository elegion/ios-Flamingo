//
//  NetworkClient.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/11/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol NetworkClient: class {
    
    @discardableResult
    func sendRequest<Request: NetworkRequest>(_ networkRequest: Request, completionHandler: ((Result<Request.Response>, NetworkContext?) -> Void)?) -> CancelableOperation?
    
}

open class NetworkDefaultClient: NetworkClient {
    private static let operationQueue = DispatchQueue(label: "com.flamingo.operation-queue", attributes: DispatchQueue.Attributes.concurrent)
    
    private let configuration: NetworkConfiguration
    
    open var session: URLSession
    
    public init(configuration: NetworkConfiguration,
                session: URLSession) {
        
        self.configuration = configuration
        self.session = session
    }
    
    private func completionQueue<Request: NetworkRequest>(for request: Request) -> DispatchQueue {
        return request.completionQueue ?? configuration.completionQueue
    }
    
    private func complete<Request: NetworkRequest>(request: Request, with completion: @escaping () -> Void) {
        completionQueue(for: request).async {
            completion()
        }
    }
    
    @discardableResult
    open func sendRequest<Request>(_ networkRequest: Request, completionHandler: ((Result<Request.Response>, NetworkContext?) -> Void)?) -> CancelableOperation? where Request : NetworkRequest {
        let urlRequest: URLRequest
        do {
            urlRequest = try self.urlRequest(from: networkRequest)
        } catch {
            complete(request: networkRequest, with: {
                completionHandler?(.error(error), nil)
            })
            
            return nil
        }
        
        let handler = self.requestHandler(with: networkRequest, urlRequest: urlRequest, completion: completionHandler)
        let task = session.dataTask(with: urlRequest, completionHandler: handler)
        task.resume()
        return task
    }
    
    private func requestHandler<Request: NetworkRequest>(with networkRequest: Request,
                                                         urlRequest: URLRequest,
                                                         completion: ((Result<Request.Response>, NetworkContext?) -> Void)?) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return {
            [unowned self] data, response, error in

            type(of: self).operationQueue.async {
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let context = NetworkContext(request: urlRequest, response: response as? HTTPURLResponse, data: data, error: Error.unableToRetrieveHTTPResponse as NSError)
                    self.complete(request: networkRequest, with: {
                        completion?(.error(Error.unableToRetrieveHTTPResponse), context)
                    })
                    return
                }
                
                let validator = Validator(request: urlRequest, response: httpResponse, data: data)
                validator.validate()
                if let validationError = validator.validationErrors.first {
                    let context = NetworkContext(request: urlRequest, response: response as? HTTPURLResponse, data: data, error: validationError as NSError)
                    self.complete(request: networkRequest, with: {
                        completion?(.error(validationError), context)
                    })
                    return
                }

                let context = NetworkContext(request: urlRequest, response: response as? HTTPURLResponse, data: data, error: error as NSError?)
                let result = networkRequest.responseSerializer.serialize(request: urlRequest, response: httpResponse, data: data, error: error)
                
                switch result {
                case .success(let value):
                    self.complete(request: networkRequest, with: {
                        completion?(.success(value), context)
                    })
                case .error(let error):
                    self.complete(request: networkRequest, with: {
                        completion?(.error(error), context)
                    })
                }
            }
        }
    }
    
    open func urlRequest<T: NetworkRequest>(from networkRequest: T) throws -> URLRequest {
        let _baseURL = networkRequest.baseURL ?? configuration.baseURL
        
        let urlString = try networkRequest.URL.asURL().absoluteString
        guard let baseURL = try _baseURL?.asURL(),
            let url = URL(string: urlString, relativeTo: baseURL) else {
                throw Error.invalidRequest
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkRequest.method.rawValue
        
        for (name, value) in (networkRequest.headers ?? [:]) {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        for (name, value) in (customHeadersForRequest(networkRequest) ?? [:]) {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        urlRequest.timeoutInterval = configuration.defaultTimeoutInterval
        
        try networkRequest.parametersEncoder.encode(parameters: networkRequest.parameters, to: &urlRequest)
        
        return urlRequest
    }
    
    open func customHeadersForRequest<T : NetworkRequest>(_ networkRequest: T) -> [String : String]? {
        return nil
    }
}
