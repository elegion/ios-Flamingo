//
//  ObjectMapperWrapper.swift
//  Example
//
//  Created by Ildar Gilfanov on 28/07/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation
import ObjectMapper
import Flamingo

class ObjectMapperWrapper<G> : Flamingo.Mapper where G: BaseMappable, G: Flamingo.Mappable {
    let objectMapper: ObjectMapper.Mapper<G>
    
    init(_ mapper: ObjectMapper.Mapper<G>) {
        objectMapper = mapper
    }
    
    func map(JSON: [String : Any]) -> G? {
        return objectMapper.map(JSON: JSON)
    }
    
    func mapArray(JSONArray: [[String : Any]]) -> [G] {
        return objectMapper.mapArray(JSONArray: JSONArray)
    }
}
