//
//  Error.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public enum Error: Swift.Error {

    /// The underlying reason the response validation error occurred.
    ///
    /// - missingContentType:      The response did not contain a `Content-Type` and the `acceptableContentTypes`
    ///                            provided did not contain wildcard type.
    /// - unacceptableContentType: The response `Content-Type` did not match any type in the provided
    ///                            `acceptableContentTypes`.
    /// - unacceptableStatusCode:  The response status code was not acceptable.
    public enum ResponseValidationFailureReason {
        case missingContentType(acceptableContentTypes: [String])
        case unacceptableContentType(acceptableContentTypes: [String], responseContentType: String)
        case unacceptableStatusCode(code: Int)
    }

    public enum ParametersEncodingErrorReason {
        case jsonEncodingFailed(Swift.Error)
        case unableToRetrieveRequestURL
        case unableToAssembleURLAfterAddingURLQueryItems
    }
    
    case invalidRequest
    case unableToRetrieveDataAndError
    case unableToRetrieveHTTPResponse
    case parametersEncodingError(ParametersEncodingErrorReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)    
}
