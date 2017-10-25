//
//  OptionalProtocol.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 20-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

internal protocol OptionalProtocol {
    func isNone() -> Bool
    func isSome() -> Bool

    var value: Any { get }
}

extension Optional: OptionalProtocol {
    public func isNone() -> Bool {
        return !self.isSome()
    }

    public func isSome() -> Bool {
        switch self {
        case .some: return true
        case .none: return false
        }
    }

    public var value: Any {
        switch self {
        case .some(let value): return value
        case .none: return self as Any
        }
    }
}
