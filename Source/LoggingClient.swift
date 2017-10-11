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

    init(for client: NetworkClient, logger: Logger) {
        self.client = client
        self.logger = logger
    }

    func sendRequest<Request>(_ networkRequest: Request, completionHandler: ((Result<Request.ResponseSerializer.Serialized>, NetworkContext?) -> Void)?) -> CancelableOperation? where Request: NetworkRequest {
        self.logger.log("Send request", context: [
            "request": networkRequest
        ])

        return self.client.sendRequest(networkRequest, completionHandler: { result, context in
            self.logger.log("Complete request", context: [
                "result": result,
                "context": context as Any
            ])

            completionHandler?(result, context)
        })
    }
}
