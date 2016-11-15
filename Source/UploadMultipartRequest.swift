//
//  UploadMultipartRequest.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 15.11.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import Foundation
import Alamofire

public struct MultipartBodyPart {
    public let data: NSData
    public let dataName: String
    public let mimeType: String
}

public protocol UploadMultipartRequest {
    func addPartsToMultipartFormData(multipartFormData: MultipartFormData)
}
