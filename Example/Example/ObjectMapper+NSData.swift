//
//  ObjectMapper+NSData.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import ObjectMapper

public extension ObjectMapper.Mappable {
    
    public func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
}

public extension Array where Element: ObjectMapper.Mappable {
    
    public func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
}

public extension Set where Element: ObjectMapper.Mappable {
    
    public func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
}
