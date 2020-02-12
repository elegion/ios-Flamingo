//
//  NetworkClientBaseTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//
//
import Flamingo

protocol StubbableClient: class {
    var stubsManager: StubsManager? { get set }

    func enableStubs()
    func disableStubs()
}

final class NetworkDefaultClientStubs: NetworkDefaultClient, StubbableClient {
    
    struct Consts {
        static let headers = [
            (name: "Accept-Language", value: "da, en-gb;q=0.8, en;q=0.7"),
            (name: "Cache-Control", value: "no-cache"),
        ]
    }

    var isUseCustomizedCustomHeaders = false

    var stubsManager: StubsManager? {
        didSet {
            if let oldValue = oldValue {
                removeMutater(oldValue)
            }
        }
    }

    func enableStubs() {
        if let stubsManager = stubsManager {
            addMutater(stubsManager)
        }
    }

    func disableStubs() {
        if let stubsManager = stubsManager {
            removeMutater(stubsManager)
        }
    }

    override func customHeadersForRequest<T: NetworkRequest>(_ networkRequest: T) -> [String: String]? {
        if !isUseCustomizedCustomHeaders {
            return super.customHeadersForRequest(networkRequest)
        }

        return Consts.headers.reduce(into: [:], {
            result, tuple in

            result[tuple.name] = tuple.value
        })
    }
}

extension NetworkDefaultClientStubs {
    
    static func defaultForTest() -> NetworkDefaultClientStubs {
        let configuration = NetworkDefaultConfiguration(baseURL: "http://example.com/", parallel: false)
        let result = NetworkDefaultClientStubs(configuration: configuration, session: .shared)
        result.stubsManager = StubsDefaultManager()
        result.enableStubs()
        return result
    }
}
