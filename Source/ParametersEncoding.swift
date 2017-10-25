//
//  ParametersEncoding.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public protocol ParametersEncoder {
    
    func encode(parameters: [String: Any]?, to request: inout URLRequest) throws
    
}

public struct URLParametersEncoder: ParametersEncoder {
    
    public init() { }
    
    public func encode(parameters: [String : Any]?, to request: inout URLRequest) throws {
        guard let parameters = parameters, !parameters.isEmpty else {
            return
        }
        guard let url = request.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error.parametersEncodingError(.unableToRetrieveRequestURL)
        }
        let queryItems = parameters.flatMap(self.queryComponents)
        if urlComponents.queryItems == nil || urlComponents.queryItems?.isEmpty == true {
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems?.append(contentsOf: queryItems)
        }
        if let resultURL = urlComponents.url {
            request.url = resultURL
        }
    }
    
    public func queryComponents(fromKey key: String, value: Any) -> [URLQueryItem] {
        var components: [URLQueryItem] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let bool = value as? Bool {
            components.append(URLQueryItem.init(name: key, value: bool ? "1" : "0"))
        } else {
            if let optionalValue = value as? OptionalProtocol {
                if optionalValue.isSome() {
                    components.append(URLQueryItem(name: key, value: "\(optionalValue.value)"))
                }
            } else {
                components.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }
        
        return components
    }
}

public struct JSONParametersEncoder: ParametersEncoder {
    
    var encodingOptions: JSONSerialization.WritingOptions
    
    public init(encodingOptions: JSONSerialization.WritingOptions = []) {
        self.encodingOptions = encodingOptions
    }
    
    public func encode(parameters: [String : Any]?, to request: inout URLRequest) throws {
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
