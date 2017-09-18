//
//  UserModels.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

class GeoLocation: Codable {
    var lat: String
    var lng: String
    
}

class Address: Codable {
    var street: String
    var suite: String
    var city: String
    var geo: GeoLocation
    
}

class Company: Codable {
    var name: String
    var catchPhrase: String
    var bs: String

}

class User: Codable {
    var id: Int
    var name: String
    var username: String
    var email: String
    var address: Address
    var phone: String
    var website: String
    var company: Company
}
