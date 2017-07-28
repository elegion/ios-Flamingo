//
//  Mapper.swift
//  Flamingo
//
//  Created by Ildar Gilfanov on 28/07/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public protocol Mapper {
    associatedtype T: Mappable
    
    func map(JSON: [String: Any]) -> T?
    func mapArray(JSONArray: [[String: Any]]) -> [T]
}
