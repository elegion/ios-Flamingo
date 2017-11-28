//
//  LoggingClient.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 11-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

class LoggingClient: NetworkClient {
    private let client: NetworkClient
    private let logger: Logger
    private var useLogger: Bool = false

    init(for client: NetworkClient, logger: Logger) {
        self.client = client
        self.logger = logger
    }

    func sendRequest<Request>(_ networkRequest: Request, completionHandler: ((Result<Request.ResponseSerializer.Serialized>, NetworkContext?) -> Void)?) -> CancelableOperation? where Request: NetworkRequest {
        let canLogging = self.useLogger

        if canLogging {
            self.logger.log("Send request", context: [
                "request": networkRequest
            ])
        }

        return self.client.sendRequest(networkRequest, completionHandler: { result, context in
            if canLogging {
                self.logger.log("Complete request", context: [
                    "result": result,
                    "context": context as Any
                ])
            }

            completionHandler?(result, context)
        })
    }

    func enableLogging() {
        self.useLogger = true
    }

    func disableLogging() {
        self.useLogger = false
    }
}
