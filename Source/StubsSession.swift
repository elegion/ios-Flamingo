//
//  StubsSession.swift
//  Flamingo
//
//  Created by Dmitrii Istratov on 03-10-2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

fileprivate typealias Stubs = [String: [HTTPMethod: ResponseStub]]

public typealias RequestHandler<T> = (Result<T>, NetworkContext?) -> Void
public typealias CompletionHandler = (Data?, URLResponse?, Swift.Error?) -> Swift.Void

public protocol StubsSession {
    func add(_ url: String, method: HTTPMethod, stub: ResponseStub) -> Self
    func add(stubs: [Stub]) -> Self
    func remove(_ url: String, method: HTTPMethod) -> Self
    func hasStub(_ url: String, method: HTTPMethod) -> Bool
    func hasStub(request: URLRequest) -> Bool
    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> CancelableOperation?
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

    private var urls: Dictionary<String, Dictionary<HTTPMethod, ResponseStub>>.Keys {
        return self.stubs.keys
    }

    init() {
        self.stubs = [:]
    }

    public func add(_ url: String, method: HTTPMethod, stub: ResponseStub) -> Self {
        let stubItem = [url: [method: stub]]
        self.add(stubsStruct: stubItem)

        return self
    }

    public func add(stubs: [Stub]) -> Self {
        let stubsItems = stubs.reduce([:], { accumulator, item -> Stubs in
            let stubItem = [item.url: [item.method: item.stub]]

            return accumulator.merging(stubItem, uniquingKeysWith: { $1 })
        })

        self.add(stubsStruct: stubsItems)

        return self
    }

    private func add(stubsStruct: Stubs) {
        self.stubs.merge(stubsStruct) { $1 }
    }

    public func remove(_ url: String, method: HTTPMethod) -> Self {
        self.stubs[url]?.removeValue(forKey: method)

        return self
    }

    public func hasStub(_ url: String, method: HTTPMethod) -> Bool {
        let stub = self.getStub(url: url, method: method)

        return stub != nil
    }

    public func hasStub(request: URLRequest) -> Bool {
        let url = request.url?.path
        let method = HTTPMethod(rawValue: request.httpMethod ?? "GET")!

        return self.hasStub(url!, method: method)
    }

    public func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler)
        -> CancelableOperation? {
        self.operationQueue.async {
            guard let url = request.url?.path,
                  let type = request.httpMethod,
                  let method = HTTPMethod(rawValue: type)
            else {
                completionHandler(nil, nil, Flamingo.Error.invalidRequest)

                return
            }

            guard let stub = self.getStub(url: url, method: method) else {
                completionHandler(nil, nil, Flamingo.Error.stubClientError(.stubNotFound))

                return
            }

            let stubData = stub.body

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: stub.statusCode.rawValue,
                httpVersion: "HTTP/1.1",
                headerFields: stub.headers
            )

            completionHandler(stubData, response, nil)
        }

        return StubTask()
    }

    private func getStub(url: String, method: HTTPMethod) -> ResponseStub? {
        let first = self.urls.first { item -> Bool in
            guard let regex = try? NSRegularExpression(
                pattern: item,
                options: NSRegularExpression.Options.caseInsensitive
            ) else {
                return false
            }

            let item = regex.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count))

            return item != nil
        }

        guard let regexUrl = first else {
            return nil
        }

        let types = self.stubs[regexUrl]!

        return types[method]
    }
}
