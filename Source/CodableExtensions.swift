//
//  CodableExtensions.swift
//  CodableExtensions
//
//  Created by James Ruston on 11/10/2017.
//

import Foundation

extension KeyedDecodingContainer {
    
    public func decode<Transformer: DecodingContainerTransformer>(_ key: KeyedDecodingContainer.Key,
                                                           transformer: Transformer) throws -> Transformer.Output where Transformer.Input: Decodable {
        let decoded: Transformer.Input = try decode(key)
        
        return try transformer.transform(decoded)
    }
    
    public func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try decode(T.self, forKey: key)
    }
    
    public func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        return try decodeIfPresent(T.self, forKey: key)
    }
    
    public func decode<Input: Decodable, Output>(_ key: KeyedDecodingContainer.Key, transform: (Input) throws -> Output) throws -> Output {
        let decoded: Input = try decode(key)

        return try transform(decoded)
    }

    public func decodeIfPresent<Input: Decodable, Output>(_ key: KeyedDecodingContainer.Key, transform: (Input) throws -> Output) throws -> Output? {
        guard let decoded: Input = try decodeIfPresent(key) else {
            return nil
        }

        return try transform(decoded)
    }
}

extension UnkeyedDecodingContainer {

    public mutating func decode<T: Decodable>() throws -> T {
        return try decode(T.self)
    }

    public mutating func decodeIfPresent<T: Decodable>() throws -> T? {
        return try decodeIfPresent(T.self)
    }

    public mutating func decode<Input: Decodable, Output>(transform: (Input) throws -> Output) throws -> Output {
        let decoded: Input = try decode()

        return try transform(decoded)
    }
    
    public mutating func decodeIfPresent<Input: Decodable, Output>(transform: (Input) throws -> Output) throws -> Output? {
        guard let decoded: Input = try decodeIfPresent() else {
            return nil
        }

        return try transform(decoded)
    }
}

extension SingleValueDecodingContainer {

    public func decode<T: Decodable>() throws -> T {
        return try decode(T.self)
    }
}

public extension KeyedEncodingContainer {
    
    mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output,
                                                                  forKey key: KeyedEncodingContainer.Key,
                                                                  transformer: Transformer) throws where Transformer.Input: Encodable {
        let transformed: Transformer.Input = try transformer.transform(value)
        try encode(transformed, forKey: key)
    }
}
