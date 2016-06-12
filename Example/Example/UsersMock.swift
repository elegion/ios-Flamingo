//
//  UsersMock.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Flamingo
import Fakery

struct UsersMock: NetworkRequestMockPrototype {
    
    var responseDelay: NSTimeInterval {
        return 3
    }
    
    var mimeType: String {
        return "application/json"
    }
    
    func responseData() -> NSData {
        let faker = Faker()
        
        var users = [User]()
        
        for _ in 0..<10 {
            let company = Company()
            
            company.name = faker.company.name()
            company.catchPhrase = faker.company.catchPhrase()
            company.bs = faker.company.bs()
            
            let location = GeoLocation()
            
            location.lat = String(faker.address.latitude())
            location.lng = String(faker.address.longitude())
            
            let address = Address()
            
            address.street = faker.address.streetName()
            address.suite = faker.address.secondaryAddress()
            address.city = faker.address.city()
            address.zipCode = faker.address.postcode()
            address.location = location
            
            let user = User()
            
            user.userId = faker.number.randomInt()
            user.name = faker.name.firstName()
            user.userName = faker.name.name()
            user.email = faker.internet.email()
            user.address = address
            user.phone = faker.phoneNumber.phoneNumber()
            user.website = faker.internet.url()
            user.company = company
            
            users.append(user)
        }
        
        return users.toNSData()
    }
}
