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
    
    public func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
}

public extension Array where Element: Mappable {
    
    public func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
}

public extension Set where Element: Mappable {
    
    public func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
}
