//
//  ObjectMapper+NSData.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import ObjectMapper

public extension Mappable {
    
    public func toNSData() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(toJSON(), options: NSJSONWritingOptions())
    }
}

public extension Array where Element: Mappable {
    
    public func toNSData() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(toJSON(), options: NSJSONWritingOptions())
    }
}

public extension Set where Element: Mappable {
    
    public func toNSData() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(toJSON(), options: NSJSONWritingOptions())
    }
}
