//
//  Logger.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 11-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public protocol Logger {
    func log(_ message: String, context: [String: Any]?)
}
