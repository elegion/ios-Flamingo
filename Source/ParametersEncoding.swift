//
//  ParametersEncoding.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol ParametersEncoder {
    
    func encode(parameters: [String: Any?]?, to request: inout URLRequest) throws
    
}

public struct URLParametersEncoder: ParametersEncoder {
    
    public func encode(parameters: [String : Any?]?, to request: inout URLRequest) throws {
        guard let stringParameters = parameters as? [String: String?] else {
            return
        }
        guard let requestURL = request.url else {
            throw Error.parametersEncodingError(.unableToRetrieveRequestURL)
        }
        
        let items = stringParameters.map(URLQueryItem.init)
        var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        if urlComponents?.queryItems != nil {
            urlComponents?.queryItems?.append(contentsOf: items)
        } else {
            urlComponents?.queryItems = items
        }
        
        guard let resultURL = urlComponents?.url else {
            throw Error.parametersEncodingError(.unableToAssembleURLAfterAddingURLQueryItems)
        }
        
        request.url = resultURL
    }
    
}

public struct JSONParametersEncoder: ParametersEncoder {
    
    var encodingOptions: JSONSerialization.WritingOptions = []
    
    public func encode(parameters: [String : Any?]?, to request: inout URLRequest) throws {
        guard let parameters = parameters else { return }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: encodingOptions)
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            request.httpBody = data
        } catch {
            throw Error.parametersEncodingError(.jsonEncodingFailed(error))
        }
    }
    
}
