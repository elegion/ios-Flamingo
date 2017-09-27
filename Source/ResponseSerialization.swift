//
//  ResponseSerialization.swift
//  Flamingo
//
//  Created by Ilya Kulebyakin on 9/12/17.
//

import Foundation

public protocol ResponseSerialization {
    
    associatedtype Serialized
    associatedtype ErrorType: Swift.Error
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Serialized, ErrorType>
}

public struct DataResponseSerializer: ResponseSerialization {

    public typealias Serialized = Data
    public typealias ErrorType = Error
    
    public init() { }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Data, ErrorType> {
        if let data = data {
            return .success(data)
        } else if let error = error {
            return .error(ResultError(error, nil))
        } else {
            return .error(ResultError(Error.unableToRetrieveDataAndError, nil))
        }
    }
    
}

public struct StringResponseSerializer: ResponseSerialization {
    
    public typealias Serialized = String
    public typealias ErrorType = Error
    
    let encoding: String.Encoding
    
    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<String, ErrorType> {
        if let data = data, let resultString = String(data: data, encoding: encoding) {
            return .success(resultString)
        } else if let error = error {
            return .error(ResultError(error, nil))
        } else {
            return .error(ResultError(Error.unableToRetrieveDataAndError, nil))
        }
    }
    
}

public struct DecodableError: Swift.Error, Decodable {

}

public struct CodableJSONSerializer<Serialized: Decodable, ErrorType: Swift.Error>: ResponseSerialization where ErrorType: Decodable {
    
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
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Serialized, ErrorType> {
        guard let data = data else {
            return .error(ResultError(error ?? Error.unableToRetrieveDataAndError, nil))
        }
        
        let result: Serialized
        do {
            result = try decoder.decode(Serialized.self, from: data)
        } catch {
            let typedError = try? decoder.decode(ErrorType.self, from: data)
            return .error(ResultError(error, typedError))
        }
        
        return .success(result)
    }
    
}
