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

internal struct URLParametersEncoder: ParametersEncoder {
    
    internal func encode(parameters: [String: Any]?, to request: inout URLRequest) throws {
        guard let parameters = parameters, !parameters.isEmpty else {
            return
        }
        
        guard let url = request.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw FlamingoError.parametersEncodingError(.unableToRetrieveRequestURL)
        }
        
        let queryItems = Self.sortedQueryItems(from: parameters)
        
        if urlComponents.queryItems == nil || urlComponents.queryItems?.isEmpty == true {
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems?.append(contentsOf: queryItems)
        }
        
        if let resultURL = urlComponents.url {
            request.url = resultURL
        }
    }
    
    internal static func sortedQueryItems(from params: [String: Any]) -> [URLQueryItem] {
        return params.flatMap(queryItems).sorted { $0.name.lexicographicallyPrecedes($1.name) }
    }
    
    internal static func queryItems(fromKey key: String, value: Any) -> [URLQueryItem] {
        var components: [URLQueryItem] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryItems(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryItems(fromKey: "\(key)[]", value: value)
            }
        } else if let bool = value as? Bool {
            components.append(URLQueryItem(name: key, value: bool ? "1" : "0"))
        } else if let optionalValue = value as? OptionalProtocol {
            if optionalValue.isSome() {
                components.append(URLQueryItem(name: key, value: "\(optionalValue.value)"))
            }
        } else {
            components.append(URLQueryItem(name: key, value: "\(value)"))
        }
        
        return components
    }
}

public struct JSONParametersEncoder: ParametersEncoder {
    
    var encodingOptions: JSONSerialization.WritingOptions
    
    public init(encodingOptions: JSONSerialization.WritingOptions = []) {
        self.encodingOptions = encodingOptions
    }
    
    public func encode(parameters: [String: Any]?, to request: inout URLRequest) throws {
        guard let parameters = parameters else { return }

        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw FlamingoError.parametersEncodingError(.jsonEncodingFailed(FlamingoError.invalidRequest))
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: encodingOptions)
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            request.httpBody = data
        } catch {
            throw FlamingoError.parametersEncodingError(.jsonEncodingFailed(error))
        }
    }
}

public struct FormURLParametersEncoder: ParametersEncoder {
    
    public init() {}
    
    public func encode(parameters: [String : Any]?, to request: inout URLRequest) throws {
        guard let parameters = parameters, !parameters.isEmpty else {
            return
        }
        
        let queryItems = URLParametersEncoder.sortedQueryItems(from: parameters)
        
        request.httpBody = queryItems
            .compactMap(string(from:))
            .joined(separator: "&")
            .data(using: .utf8)
    }
    
    private func string(from item: URLQueryItem) -> String? {
        return item.value.map { escape(item.name) + "=" + escape($0) }
    }
    
    /// Returns a string escaped for `application/x-www-form-urlencoded` encoding.
    ///
    /// - parameter str: The string to encode.
    ///
    /// - returns: The encoded string.
    
    private func escape(_ str: String) -> String {
        // Convert LF to CR LF, then
        // Percent encoding anything that's not allow (this implies UTF-8), then
        // Convert " " to "+".
        //
        // Note: We worry about `addingPercentEncoding(withAllowedCharacters:)` returning nil
        // because that can only happen if the string is malformed (specifically, if it somehow
        // managed to be UTF-16 encoded with surrogate problems) <rdar://problem/28470337>.
        
        return str
            .replacingOccurrences(of: "\n", with: "\r\n")
            .addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
            .replacingOccurrences(of: " ", with: "+")
    }
    
    /// The characters that are don't need to be percent encoded in an `application/x-www-form-urlencoded` value.
    
    private let allowedCharacters: CharacterSet = {
        // Start with `CharacterSet.urlQueryAllowed` then add " " (it's converted to "+" later)
        // and remove "+" (it has to be percent encoded to prevent a conflict with " ").
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(" ")
        allowed.remove("+")
        allowed.remove("/")
        allowed.remove("?")
        
        return allowed
    }()
}
