//
//  SimpleLogger.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 11-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

class SimpleLogger: Logger {
    private let appName: String

    init(appName: String) {
        self.appName = appName
    }

    func log(_ message: String, context: [String: Any]? = nil) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        let formattedDate = formatter.string(from: date)
        var start = "\(formattedDate) \(self.appName): \(message)"
        if let context = context,
            !context.isEmpty {
            start += ", context: {\(String(describing: context))}"
            start += ", context: {\(context)}"
        }

        print(start)
    }
}
