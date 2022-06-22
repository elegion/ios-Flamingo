//
//  NetworkClientReporter.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 23.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public protocol NetworkClientReporter: AnyObject {
    func willSendRequest<Request: NetworkRequest>(_ networkRequest: Request)
    func didRecieveResponse<Request: NetworkRequest>(for request: Request,
                                                     context: NetworkContext)
}
