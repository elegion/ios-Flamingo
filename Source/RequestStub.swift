//
//  RequestStub.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public struct RequestStub: Hashable {
    public let url: URL
    public let method: HTTPMethod
    public let query: [String: Any]?
    public let body: [String: Any]?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(method)
        hasher.combine(NSDictionary(dictionary: query ?? [:]))
        hasher.combine(NSDictionary(dictionary: body ?? [:]))
    }
    
    public init(url: URL, method: HTTPMethod, query: [String: Any]? = nil, body: [String: Any]? = nil) {
        self.url = url
        self.method = method
        self.query = query
        self.body = body
    }
    
    public init?<Request: NetworkRequest>(_ request: Request) {
        guard let requestURL = (try? request.URL.asURL()) else {
            return nil
        }
        
        self.init(url: requestURL, method: request.method, query: request.query, body: request.body?.parameters)
    }
    
    public static func ==(lhs: RequestStub, rhs: RequestStub) -> Bool {
        let checkEquality = {
            (lhs: [String: Any]?, rhs: [String: Any]?) -> Bool in
            
            return NSDictionary(dictionary: lhs ?? [:]).isEqual(to: rhs ?? [:])
        }
        
        let areQueriesEqual = checkEquality(lhs.query, rhs.query)
        let areBodiesEqual = checkEquality(lhs.body, rhs.body)
        
        return lhs.url == rhs.url
            && lhs.method == rhs.method
            && areQueriesEqual
            && areBodiesEqual
    }
}
