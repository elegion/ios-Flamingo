//
//  StubError.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 04.03.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public enum StubError: Swift.Error, LocalizedError {

    public enum StubClientFactoryErrorReason: CustomStringConvertible {
        case fileNotExists(String)
        case cannotAccessToFile(String)
        case wrongFileContent
        case wrongListFormat

        public var description: String {
            switch self {
            case .fileNotExists(let string):
                return "File not exists. \(string)"
            case .cannotAccessToFile(let string):
                return "Cannot access to file. \(string)"
            case .wrongFileContent:
                return "Wrong file content"
            case .wrongListFormat:
                return "Wrong list format"
            }
        }
    }

    public enum StubClientErrorReason: CustomStringConvertible {
        case stubNotFound

        public var description: String {
            switch self {
            case .stubNotFound:
                return "Stub not found"
            }
        }
    }

    case stubClientFactoryError(StubClientFactoryErrorReason)
    case stubClientError(StubClientErrorReason)

    public var localizedDescription: String {
        switch self {
        case .stubClientFactoryError(let reason):
            return "Stub client factory error. \(reason)"
        case .stubClientError(let reason):
            return "Stub client error. \(reason)"
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }
}
