//
//  NetworkContext.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/11/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public struct NetworkContext {
    
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: NSError?
    
    init(request: URLRequest?,
         response: HTTPURLResponse?,
         data: Data?,
         error: NSError?) {
        
        self.request = request
        self.response = response
        self.data = data
        self.error = error
    }
}

extension NetworkContext: CustomStringConvertible {
    public var description: String {
        var dataAsString: String = ""
        if let data = data {
            dataAsString = String(data: data, encoding: .utf8) ?? ""
        }
        let dataWithHeader = (!dataAsString.isEmpty ? "\n    data as string: \(dataAsString)" : "")
        return """
        Network context: \(String(describing: type(of: self)))
            response: \(String(describing: self.response))
            data: \(String(describing: self.data))\(dataWithHeader)
            error: \(String(describing: self.error))
        """
    }
}
