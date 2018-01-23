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
    func addReporter(_ reporter: NetworkClientReporter)
    func removeReporter(_ reporter: NetworkClientReporter)
}

open class NetworkDefaultClient: NetworkClient {
    private static let operationQueue = DispatchQueue(label: "com.flamingo.operation-queue", attributes: DispatchQueue.Attributes.concurrent)
    
    private let configuration: NetworkConfiguration
    
    open var session: URLSession

    private var reporters = ObserversArray<NetworkClientReporter>()
    
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
        reporters.invoke {
            (reporter) in
            reporter.willSendRequest(networkRequest)
        }
        return task
    }

    public func addReporter(_ reporter: NetworkClientReporter) {
        reporters.addObserver(observer: reporter)
    }

    public func removeReporter(_ reporter: NetworkClientReporter) {
        reporters.removeObserver(observer: reporter)
    }
    
    private func requestHandler<Request: NetworkRequest>(with networkRequest: Request,
                                                         urlRequest: URLRequest,
                                                         completion: ((Result<Request.Response>, NetworkContext?) -> Void)?) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return {
            [weak self] data, response, error in

            NetworkDefaultClient.operationQueue.async {

                guard let sself = self else {
                    return
                }

                var finalError: Swift.Error? = error
                let httpResponse = response as? HTTPURLResponse

                let failureClosure = {
                    self?.complete(request: networkRequest, with: {
                        let context = NetworkContext(request: urlRequest, response: httpResponse, data: data, error: finalError as NSError?)

                        self?.reporters.invoke {
                            (reporter) in
                            reporter.didRecieveResponse(for: networkRequest, context: context)
                        }
                        
                        completion?(.error(finalError ?? Error.invalidRequest), context)
                    })
                }

                if error != nil {
                    failureClosure()
                    return
                }

                if httpResponse == nil {
                    finalError = Error.unableToRetrieveHTTPResponse
                    failureClosure()
                    return
                }
                
                let validator = Validator(request: urlRequest, response: httpResponse, data: data)
                validator.validate()
                if let validationError = validator.validationErrors.first {
                    finalError = validationError
                    failureClosure()
                    return
                }

                let context = NetworkContext(request: urlRequest, response: httpResponse, data: data, error: finalError as NSError?)
                let result = networkRequest.responseSerializer.serialize(request: urlRequest, response: httpResponse, data: data, error: error)
                
                switch result {
                case .success(let value):
                    sself.complete(request: networkRequest, with: {
                        self?.reporters.invoke {
                            (reporter) in
                            reporter.didRecieveResponse(for: networkRequest, context: context)
                        }

                        completion?(.success(value), context)
                    })
                case .error(let error):
                    finalError = error
                    failureClosure()
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
