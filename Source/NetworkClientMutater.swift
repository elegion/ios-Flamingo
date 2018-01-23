//
//  NetworkClientMutater.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 23.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public protocol NetworkClientMutater: class {
    typealias RawResponseTuple = (data: Data?, response: URLResponse?, error: Swift.Error?)

    func reponse<Request: NetworkRequest>(for request: Request) -> RawResponseTuple?
}
