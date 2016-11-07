//
//  NetworkContext.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 11.08.16.
//  Copyright © 2016 ELN. All rights reserved.
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
