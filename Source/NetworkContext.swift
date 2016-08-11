//
//  NetworkContext.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 11.08.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

public struct NetworkContext {
    
    public let request: NSURLRequest?
    public let response: NSHTTPURLResponse?
    public let data: NSData?
    public let error: NSError?
    
    init(request: NSURLRequest?,
         response: NSHTTPURLResponse?,
         data: NSData?,
         error: NSError?) {
        
        self.request = request
        self.response = response
        self.data = data
        self.error = error
    }
}
