//
//  NSError+Flamingo.swift
//  Flamingo
//
//  Created by Sergey Rakov on 15.06.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

extension NSError {
    
    var isNetworkConnectionError: Bool {
        if domain == NSURLErrorDomain {
            switch code {
            case NSURLErrorTimedOut,
                 NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorNotConnectedToInternet,
                 NSURLErrorInternationalRoamingOff,
                 NSURLErrorCallIsActive,
                 NSURLErrorDataNotAllowed:
                return true
            default: ()
            }
        }
        
        if let underlyingError = (userInfo as! [String : AnyObject])[NSUnderlyingErrorKey] as? NSError {
            return underlyingError.isNetworkConnectionError
        } else {
            return false
        }
    }
}
