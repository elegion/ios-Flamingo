//
//  NetworkClientReporter.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 23.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public protocol NetworkClientReporter: class {
    func willSendRequest(_ networkRequest: NetworkRequest)
    func didRecieveResponse(_ urlResponse: URLResponse)
}
