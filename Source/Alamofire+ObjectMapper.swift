//
//  Alamofire+ObjectMapper.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public struct ObjectMapperError {
    
    public static let Domain = "com.objectmapper.error"
    
    public enum Code: Int {
        case MappingFailed = 1
    }
    
    public static func errorWithCode(code: Code, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        
        return NSError(domain: Domain, code: code.rawValue, userInfo: userInfo)
    }
}

public struct AlamofireObjectMapperFactory<T: Mappable> {
    
    public init() {}
    
    public func dictionaryResponseSerializer() -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            let jsonSerializer = Request.JSONResponseSerializer()
            
            let result = jsonSerializer.serializeResponse(request, response, data, error)
            
            switch(result) {
            case .Success(let value):
                if let responseObject = Mapper<T>().map(value) {
                    return .Success(responseObject)
                }
                
                let mappingError = ObjectMapperError.errorWithCode(.MappingFailed, failureReason: "Object \(value) could not be mapped into object of type \(T.self)")
                
                return .Failure(mappingError)
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }
    
    public func arrayResponseSerializer() -> ResponseSerializer<[T], NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            let jsonSerializer = Request.JSONResponseSerializer()
            
            let result = jsonSerializer.serializeResponse(request, response, data, error)
            
            switch(result) {
            case .Success(let value):
                if let responseObject = Mapper<T>().mapArray(value) {
                    return .Success(responseObject)
                }
                
                let mappingError = ObjectMapperError.errorWithCode(.MappingFailed, failureReason: "Object \(value) could not be mapped into array of objects of type \(T.self)")
                
                return .Failure(mappingError)
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }
}
