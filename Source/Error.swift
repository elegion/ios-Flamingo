//
//  Error.swift
//  Flamingo 1.0
//
//  Created by Ilya Kulebyakin on 9/15/17.
//  Copyright © 2017 e-Legion. All rights reserved.
//

import Foundation

public enum Error: Swift.Error {
    
    case invalidRequest
    case unableToGenerateContext
    case unableToRetrieveDataAndError
    case parametersEncodingError(ParametersEncodingErrorReason)
    
}

public enum ParametersEncodingErrorReason {
    
    case jsonEncodingFailed(Swift.Error)
    case unableToRetrieveRequestURL
    case unableToAssembleURLAfterAddingURLQueryItems
    
}
