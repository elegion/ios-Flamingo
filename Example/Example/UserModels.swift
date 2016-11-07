//
//  UserModels.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import ObjectMapper

class GeoLocation: Mappable {
    var lat: String!
    var lng: String!
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        lat     <- map["lat"]
        lng     <- map["lng"]
    }
}

class Address: Mappable {
    var street: String!
    var suite: String!
    var city: String!
    var zipCode: String!
    var location: GeoLocation!
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        street      <- map["street"]
        suite       <- map["suite"]
        city        <- map["city"]
        zipCode     <- map["zipcode"]
        location    <- map["geo"]
    }
}

class Company: Mappable {
    var name: String!
    var catchPhrase: String!
    var bs: String!
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name            <- map["name"]
        catchPhrase     <- map["catchPhrase"]
        bs              <- map["bs"]
    }
}

class User: Mappable {
    var userId: Int!
    var name: String!
    var userName: String!
    var email: String!
    var address: Address!
    var phone: String!
    var website: String!
    var company: Company!
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId      <- map["id"]
        name        <- map["name"]
        userName    <- map["username"]
        email       <- map["email"]
        address     <- map["address"]
        phone       <- map["phone"]
        website     <- map["website"]
        company     <- map["company"]
    }
}
