//
//  LoggingClient.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 11-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

open class LoggingClient: NetworkClientReporter {
    private let logger: Logger
    open var useLogger: Bool = true

    public init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - NetworkClientReporter

    open func willSendRequest<Request>(_ networkRequest: Request) where Request: NetworkRequest {
        guard useLogger else {
            return
        }

        logger.log("Send request", context: [
            "request": networkRequest,
            ])
    }

    open func didRecieveResponse<Request>(for request: Request, context: NetworkContext) where Request: NetworkRequest {
        guard useLogger else {
            return
        }

        var dataAsString: String?
        if let data = context.data {
            dataAsString = String(data: data, encoding: .utf8)
        }
        var context: [String: Any] = ["request": request,
                                      "context": context]
        if let dataAsString = dataAsString {
            context["data as string"] = dataAsString
        }
        logger.log("Complete request", context: context)
    }
}
