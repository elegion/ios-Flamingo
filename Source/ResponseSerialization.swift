//
//  ResponseSerialization.swift
//  Flamingo
//
//  Created by Ilya Kulebyakin on 9/12/17.
//

import Foundation

public protocol ResponseSerialization {
    
    associatedtype Serialized
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Serialized>
    
}

public struct DataResponseSerializer: ResponseSerialization {
    
    public typealias Serialized = Data
    
    public init() { }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Data> {
        if let data  = data {
            return .success(data)
        } else if let error = error {
            return .error(error)
        } else {
            return .error(Error.unableToRetrieveDataAndError)
        }
    }
    
}

public struct StringResponseSerializer: ResponseSerialization {
    
    public typealias Serialized = String
    
    let encoding: String.Encoding
    
    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<String> {
        if let data = data, let resultString = String(data: data, encoding: encoding) {
            return .success(resultString)
        } else if let error = error {
            return .error(error)
        } else {
            return .error(Error.unableToRetrieveDataAndError)
        }
    }
    
}

public struct CodableJSONSerializer<Serialized: Decodable>: ResponseSerialization {
    
    let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw) {
        self.init(decoder: JSONDecoder())
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Serialized> {
        guard let data = data else {
            return .error(error ?? Error.unableToRetrieveDataAndError)
        }
        
        let result: Serialized
        do {
            result = try decoder.decode(Serialized.self, from: data)
        } catch {
            return .error(error)
        }
        
        return .success(result)
    }
    
}
