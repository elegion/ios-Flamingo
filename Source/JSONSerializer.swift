//
//  JSONSerializer.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public class JSONSerializer {
    let decoder: JSONDecoder

    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    public convenience init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy

        self.init(decoder: decoder)
    }

    public func deserialize<Serialized: Decodable>(data: Data) -> Result<Serialized> {
        var result: Serialized
        do {
            result = try decoder.decode(Serialized.self, from: data)
        } catch {
            return .error(error)
        }

        return .success(result)
    }

    public func deserialize<Serialized: Decodable>(string: String) -> Result<Serialized> {
        let data = string.data(using: .utf8)

        return self.deserialize(data: data!)
    }
}
