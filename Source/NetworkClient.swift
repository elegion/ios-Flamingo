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
    func sendRequest<Request: NetworkRequest>(_ networkRequest: Request, completionHandler: ((Result<Request.Response, Request.ErrorType>, NetworkContext?) -> Void)?) -> CancelableOperation?
    
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
    open func sendRequest<Request>(_ networkRequest: Request, completionHandler: ((Result<Request.Response, Request.ErrorType>, NetworkContext?) -> Void)?) -> CancelableOperation? where Request : NetworkRequest {
        let urlRequest: URLRequest
        do {
            urlRequest = try self.urlRequest(from: networkRequest)
        } catch {
            complete(request: networkRequest, with: {
                completionHandler?(.error(ResultError(error, nil)), nil)
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
                                                         completion: ((Result<Request.Response, Request.ErrorType>, NetworkContext?) -> Void)?) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return {
            [unowned self] data, response, error in

            if let response = response,
                self.configuration.debugMode {
                if let data = data,
                    let dataAsString = String(data: data, encoding: .utf8) {

                    self.debugPrint(response, dataAsString)
                } else {
                    self.debugPrint(response)
                }
            }
            
            type(of: self).operationQueue.async {
                let context = NetworkContext(request: urlRequest, response: response as? HTTPURLResponse, data: data)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.complete(request: networkRequest, with: {
                        completion?(.error(ResultError(Error.unableToRetrieveHTTPResponse, nil)), context)
                    })
                    return
                }
                
                let result = networkRequest.responseSerializer.serialize(request: urlRequest, response: httpResponse, data: data, error: error)

                let validator = Validator(request: urlRequest, response: httpResponse, data: data)
                validator.validate()
                if let validationError = validator.validationErrors.first {
                    self.complete(request: networkRequest, with: {
                        completion?(.error(ResultError(validationError, result.typedError)), context)
                    })
                    return
                }

                self.complete(request: networkRequest, with: {
                    completion?(result, context)
                })
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

    public func debugPrint(_ items: Any...) {
        Swift.debugPrint(String(describing: type(of: self).self), items)
    }
}
