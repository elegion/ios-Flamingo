//
//  StubsSession.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

fileprivate typealias Stubs = [RequestStub: ResponseStub]

public typealias RequestHandler<T> = (Result<T>, NetworkContext?) -> Void
public typealias CompletionHandler = (Data?, URLResponse?, Swift.Error?) -> Swift.Void

public protocol StubsSession {
    func add(_ key: RequestStub, stub: ResponseStub)
    func add(stubs: [RequestStubMap])
    func remove(_ key: RequestStub)
    func hasStub(_ key: RequestStub) -> Bool
}

private class StubTask: CancelableOperation {
    public func cancelOperation() {}
}

public class StubDefaultSession: StubsSession {

    private let operationQueue = DispatchQueue(
        label: "com.flamingo.operation-queue",
        attributes: DispatchQueue.Attributes.concurrent
    )

    private var stubs: Stubs

    private var urls: [String] {
        return self.stubs.keys.map({ $0.url })
    }

    init() {
        self.stubs = [:]
    }

    public func add(_ key: RequestStub, stub: ResponseStub) {
        let stubItem = [key: stub]
        self.add(stubsStruct: stubItem)
    }

    public func add(stubs: [RequestStubMap]) {
        for i in stubs.indices {
            self.stubs[stubs[i].requestStub] = stubs[i].stub
        }
    }

    public func remove(_ key: RequestStub) {
        stubs.removeValue(forKey: key)
    }

    public func hasStub(_ key: RequestStub) -> Bool {
        return stubs[key] != nil
    }

    private func add(stubsStruct: Stubs) {
        self.stubs.merge(stubsStruct) { $1 }
    }
}
