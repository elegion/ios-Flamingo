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
        case mappingFailed = 1
    }
    
    public static func errorWithCode(code: Code, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        
        return NSError(domain: Domain, code: code.rawValue, userInfo: userInfo)
    }
}

public extension DataResponseSerializer where Value: Mappable {
    
    public static func dictionaryResponseSerializer() -> DataResponseSerializer<Value> {
        return DataResponseSerializer<Value> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            let result = Request.serializeResponseJSON(options: [], response: response, data: data, error: error)

            switch(result) {
            case .success(let value):
                if let json = value as? [String: Any] {
                    if let responseObject = Mapper<Value>().map(JSON: json) {
                        return .success(responseObject)
                    }
                }
                
                let mappingError = ObjectMapperError.errorWithCode(code: .mappingFailed, failureReason: "Object \(value) could not be mapped into object of type \(Value.self)")
                
                return .failure(mappingError)
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    public static func arrayResponseSerializer() -> DataResponseSerializer<[Value]> {
        return DataResponseSerializer<[Value]> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            let result = Request.serializeResponseJSON(options: [], response: response, data: data, error: error)
            
            switch(result) {
            case .success(let value):
                if let jsonArray = value as? [[String: Any]] {
                    let responseObject = Mapper<Value>().mapArray(JSONArray: jsonArray)
                    if responseObject.count == jsonArray.count {
                        return .success(responseObject)
                    }
                }
                
                let mappingError = ObjectMapperError.errorWithCode(code: .mappingFailed, failureReason: "Object \(value) could not be mapped into array of objects of type \(Value.self)")
                
                return .failure(mappingError)
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
