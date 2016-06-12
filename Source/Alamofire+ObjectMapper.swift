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

public extension ResponseSerializer where Value: Mappable {
    
    public static func dictionaryResponseSerializer() -> ResponseSerializer<Value, NSError> {
        return ResponseSerializer<Value, NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            let jsonSerializer = Request.JSONResponseSerializer()
            
            let result = jsonSerializer.serializeResponse(request, response, data, error)
            
            switch(result) {
            case .Success(let value):
                if let responseObject = Mapper<Value>().map(value) {
                    return .Success(responseObject)
                }
                
                let mappingError = ObjectMapperError.errorWithCode(.MappingFailed, failureReason: "Object \(value) could not be mapped into object of type \(Value.self)")
                
                return .Failure(mappingError)
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }
    
    public static func arrayResponseSerializer() -> ResponseSerializer<[Value], NSError> {
        return ResponseSerializer<[Value], NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            let jsonSerializer = Request.JSONResponseSerializer()
            
            let result = jsonSerializer.serializeResponse(request, response, data, error)
            
            switch(result) {
            case .Success(let value):
                if let responseObject = Mapper<Value>().mapArray(value) {
                    return .Success(responseObject)
                }
                
                let mappingError = ObjectMapperError.errorWithCode(.MappingFailed, failureReason: "Object \(value) could not be mapped into array of objects of type \(Value.self)")
                
                return .Failure(mappingError)
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }
}
