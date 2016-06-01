//
//  NetworkRequestMock.swift
//  Flamingo
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation

public protocol NetworkRequestMockPrototype {
    
    var responseDelay: NSTimeInterval { get }
    var mimeType: String { get }
    
    func responseData() -> NSData
}
