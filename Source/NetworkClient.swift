//
//  NetworkClient.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/11/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public typealias CompletionHandler<T> = (Result<T, Error>, NetworkContext?) -> Void

public protocol NetworkClient: class {
    
    @discardableResult
    func sendRequest<Request: NetworkRequest>(_ networkRequest: Request, completionHandler: ((Result<Request.Response, Error>, NetworkContext?) -> Void)?) -> Cancellable
    func addReporter(_ reporter: NetworkClientReporter, storagePolicy: StoragePolicy)
    func removeReporter(_ reporter: NetworkClientReporter)
}

public protocol NetworkClientMutable: NetworkClient {

    func addMutater(_ mutater: NetworkClientMutater, storagePolicy: StoragePolicy)
    func removeMutater(_ mutater: NetworkClientMutater)
}

open class NetworkDefaultClient: NetworkClientMutable {
    private static let operationQueue = DispatchQueue(label: "com.flamingo.operation-queue", attributes: DispatchQueue.Attributes.concurrent)
    
    private let configuration: NetworkConfiguration
    
    open var session: URLSession

    private var reporters = ObserversArray<NetworkClientReporter>()

    private var mutaters = ObserversArray<NetworkClientMutater>()
    
    public init(configuration: NetworkConfiguration,
                session: URLSession) {
        
        self.configuration = configuration
        self.session = session
    }
    
    private func completionQueue<Request: NetworkRequest>(for request: Request) -> DispatchQueue {
        return request.completionQueue ?? configuration.completionQueue
    }
    
    private func complete<Request: NetworkRequest>(request: Request, with completion: @escaping () -> Void) {
        if configuration.parallel {
            completionQueue(for: request).async {
                completion()
            }
        } else {
            completion()
        }
    }
    
    @discardableResult
    open func sendRequest<Request>(_ networkRequest: Request, completionHandler: CompletionHandler<Request.Response>?) -> Cancellable where Request: NetworkRequest {
        let urlRequest: URLRequest
        do {
            urlRequest = try self.urlRequest(from: networkRequest)
        } catch {
            complete(request: networkRequest, with: {
                completionHandler?(.failure(error), nil)
            })
            
            return EmptyCancellable()
        }
        reporters.iterate {
            (reporter, _) in
            reporter.willSendRequest(networkRequest)
        }
        
        let handler = self.requestHandler(with: networkRequest, urlRequest: urlRequest, completion: completionHandler)
        var foundResponse = false
        mutaters.iterate {
            (mutater, _) in
            if !foundResponse,
                let responseTuple = mutater.response(for: networkRequest) {
                handler(responseTuple.data, responseTuple.response, responseTuple.error)
                foundResponse = true
            }
        }
        if !foundResponse {
            let task = session.dataTask(with: urlRequest, completionHandler: handler)
            task.resume()
            return task
        }

        return EmptyCancellable()
    }

    public func addReporter(_ reporter: NetworkClientReporter, storagePolicy: StoragePolicy = .weak) {
        reporters.addObserver(observer: reporter, storagePolicy: storagePolicy)
    }

    public func removeReporter(_ reporter: NetworkClientReporter) {
        reporters.removeObserver(observer: reporter)
    }

    /// Add another mutater
    ///
    /// Priority will be the same as you add them
    /// - Parameter mutater: NetworkClientMutater conformance
    public func addMutater(_ mutater: NetworkClientMutater, storagePolicy: StoragePolicy = .weak) {
        mutaters.addObserver(observer: mutater, storagePolicy: storagePolicy)
    }

    public func removeMutater(_ mutater: NetworkClientMutater) {
        mutaters.removeObserver(observer: mutater)
    }
    
    private func requestHandler<Request: NetworkRequest>(with networkRequest: Request,
                                                         urlRequest: URLRequest,
                                                         completion: ((Result<Request.Response, Error>, NetworkContext) -> Void)?) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return {
            [weak self] data, response, error in

            let failureClosure = {
                (finalError: Swift.Error?, httpResponse: HTTPURLResponse?) in

                self?.complete(request: networkRequest, with: {
                    let context = NetworkContext(request: urlRequest, response: httpResponse, data: data, error: finalError as NSError?)

                    self?.reporters.iterate {
                        (reporter, _) in
                        reporter.didRecieveResponse(for: networkRequest, context: context)
                    }

                    completion?(.failure(finalError ?? FlamingoError.invalidRequest), context)
                })
            }

            let jobClosure = {

                var finalError: Swift.Error? = error
                let httpResponse = response as? HTTPURLResponse

                if error != nil {
                    failureClosure(finalError, httpResponse)
                    return
                }

                if httpResponse == nil {
                    finalError = error ?? FlamingoError.unableToRetrieveHTTPResponse
                    failureClosure(finalError, httpResponse)
                    return
                }

                let validator = Validator(request: urlRequest, response: httpResponse, data: data)
                validator.validate()
                if let validationError = validator.validationErrors.first {
                    finalError = validationError
                    failureClosure(finalError, httpResponse)
                    return
                }

                let context = NetworkContext(request: urlRequest, response: httpResponse, data: data, error: finalError as NSError?)
                let result = networkRequest.responseSerializer.serialize(request: urlRequest, response: httpResponse, data: data, error: error)

                switch result {
                case .success(let value):
                    self?.complete(request: networkRequest, with: {
                        self?.reporters.iterate {
                            (reporter, _) in
                            reporter.didRecieveResponse(for: networkRequest, context: context)
                        }

                        completion?(.success(value), context)
                    })
                case .failure(let error):
                    finalError = error
                    failureClosure(finalError, httpResponse)
                }
            }

            if let configuration = self?.configuration,
                configuration.parallel {
                NetworkDefaultClient.operationQueue.async(execute: jobClosure)
            } else {
                jobClosure()
            }
        }
    }
    
    open func urlRequest<T: NetworkRequest>(from networkRequest: T) throws -> URLRequest {
        let _baseURL = networkRequest.baseURL ?? configuration.baseURL
        
        let urlString = try networkRequest.URL.asURL().absoluteString
        guard let baseURL = try _baseURL?.asURL(),
            let url = URL(string: urlString, relativeTo: baseURL) else {
                throw FlamingoError.invalidRequest
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkRequest.method.rawValue
        
        networkRequest.headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        customHeadersForRequest(networkRequest)?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
 
        urlRequest.timeoutInterval = configuration.defaultTimeoutInterval
        
        if let cachePolicy = networkRequest.cachePolicy {
            urlRequest.cachePolicy = cachePolicy
        }

        if let query = networkRequest.query {
            try URLParametersEncoder().encode(parameters: query, to: &urlRequest)
        }
        
        if let body = networkRequest.body {
            try body.encoder.encode(parameters: body.parameters, to: &urlRequest)
        }
        
        return urlRequest
    }
    
    open func customHeadersForRequest<T: NetworkRequest>(_ networkRequest: T) -> [String: String]? {
        return nil
    }
}
