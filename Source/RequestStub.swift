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
    public let params: [String: Any]?
    public var hashValue: Int

    public init(url: URL, method: HTTPMethod, params: [String: Any]? = nil) {
        self.url = url
        self.method = method
        self.params = params
        hashValue = "\(url)\(method)\(params ?? [:])".hashValue
    }

    public static func ==(lhs: RequestStub, rhs: RequestStub) -> Bool {
        let equalParams = NSDictionary(dictionary: lhs.params ?? [:]).isEqual(to: rhs.params ?? [:])
        return lhs.url == rhs.url &&
            lhs.method == rhs.method &&
        equalParams
    }
}
