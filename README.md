![Flamingo](https://github.com/elegion/ios-Flamingo/blob/master/logo.png)

[![Build Status](https://travis-ci.org/elegion/ios-Flamingo.svg?branch=master)](https://travis-ci.org/elegion/ios-Flamingo)
[![License](https://img.shields.io/github/license/elegion/Flamingo.svg)](LICENSE)

## Description

Lightweight and easy to use Swift network manager. Based on `URLSession` and `Swift.Codable`.

Supported features:
* Performing http requests
* Easy response mapping
* Easy response stubbing

## Installation

With CocoaPods:

```
source 'https://github.com/elegion/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'Flamingo'
```

With Carthage:

```
github "elegion/ios-Flamingo"
```

## Usage

### Basic usage

#### Setup configuration

Create default network configuration:

```swift
let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/")
```

#### Setup network client

```swift
let networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
```

#### Setup request info

Satisfy `NetworkRequest` protocol to add request (see more information below about response mapping):

```swift
struct UsersRequest: NetworkRequest {

    init() {

    }

    // MARK: - Implementation

    var URL: URLConvertible {
        return "users"
    }

    var useCache: Bool {
        return true
    }

    var responseSerializer: CodableJSONSerializer<[User]> {
        return CodableJSONSerializer<[User]>()
    }
}
```

#### Map responses

Map responses with custom implementation of `ResponseSerialization` or use one of the predefined `DataResponseSerializer`, `StringResponseSerializer`, `CodableJSONSerializer`:

```swift
struct UsersRequest: NetworkRequest {
    ...
    var responseSerializer: CodableJSONSerializer<[User]> {
        return CodableJSONSerializer<[User]>()
    }
    ...
}

class Address: Codable {
    var street: String
    var suite: String
    var city: String
    var geo: GeoLocation
}

class Company: Codable {
    var name: String
    var catchPhrase: String
    var bs: String
}

class User: Codable {
    var id: Int
    var name: String
    var username: String
    var email: String
    var address: Address
    var phone: String
    var website: String
    var company: Company
}
```

You can also create your own serializers. See `ResponseSerialization` for more details.

#### Send request

```swift
let request = UsersRequest()

networkClient.sendRequest(request) {
    (result, _) in

    switch result {
    case .success(let users):
        XCTAssert(!users.isEmpty, "Users array is empty")
    case .error(let error):
        XCTFail("User not recieved, error: \(error)")
    }
    asyncExpectation.fulfill()
}
```

### Client customization

#### Custom configuration types

Create custom configuration structure if you need more information to initialize client:
```swift
public struct NetworkCustomConfiguration: NetworkConfiguration {
    
    public let baseURL: URLStringConvertible?
    public let useMocks: Bool
    public let completionQueue: DispatchQueue
    public let defaultTimeoutInterval: TimeInterval
    public let clientToken: String?
    
    public init(baseURL: URLStringConvertible? = nil,
                debugMode: Bool = false,
                completionQueue: DispatchQueue = DispatchQueue.main,
                defaultTimeoutInterval: TimeInterval = 60.0,
                clientToken: String?) {
        
        self.baseURL = baseURL
        self.useMocks = useMocks
        self.debugMode = debugMode
        self.completionQueue = completionQueue
        self.defaultTimeoutInterval = defaultTimeoutInterval
        self.clientToken = clientToken
    }
}
...
let configuration = NetworkCustomConfiguration(baseURL: "http://jsonplaceholder.typicode.com/",
                                               clientToken: "202cb962ac59075b964b07152d234b70")

```

### Stubs and mocks

There is `StubsDefaultManager` that can handle almost all mock logic, but still you can create your own, by conforming to `NetworkClientMutater`. `StubsDefaultManager` can be easily created from file by using `StubsManagerFactory`. `StubsList.json`  is a great stubs file example. Stubs also can be added using `protocol StubsManager` methods.

### Logging and reporting

To log requests and responses you can create instance of `LogginClient` and pass it to your network client using `func addReporter(_ reporter: NetworkClientReporter, storagePolicy: StoragePolicy)`. `LogginClient` can be constructed with `SimpleLogger` or your own implementation of `Logger` protocol.
Also `OfflineCacheManager` is a great example of implementing `NetworkClientReporter, NetworkClientMutater` protocols.

### Codable extensions

https://github.com/jamesruston/CodableExtensions is integrated, so you don't need to embed them as a framework.

## Requirements

Swift 4.1, xCode 9.1

## Author

e-Legion

## License

Flamingo is available under the MIT license. See the LICENSE file for more info.

## TODOs

1) Documentation
2) Test coverage
3) Redirect handle
4) Error's localisation
5) Null in stubs

## P.S.

Pull requests are welcome 💪🏻
