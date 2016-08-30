![Flamingo](https://github.com/elegion/ios-Flamingo/blob/master/logo.png)

## Description

Swift network manager. Based on `Alamofire`, `ObjectMapper` and `Cache`.
Supported features:
* Performing http requests
* Easy response mapping
* Offline mode caching out-of-the-box
* Request mocks

## Installation

With CocoaPods:

```
source 'https://github.com/elegion/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'Flamingo'
```

## Usage

### Basic usage

#### Setup configuration

Create default network configuration:

```swift
let configuration = NetworkDefaultConfiguration()
```
```swift
let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/",
                                                debugMode: true,
                                                completionQueue: dispatch_get_main_queue(),
                                                defaultTimeoutInterval: 10)
```

#### Setup network client

```swift
let networkClient = NetworkDefaultClient(configuration: configuration)
```

#### Setup request info

Satisfy `NetworkRequest` protocol to add request (see more information below about response mapping):

```swift
struct UsersRequest: NetworkRequest {
    
    var URL: URLStringConvertible {
        return "users"
    }
    
    var useCache: Bool {
        return true
    }
    
    var responseSerializer: ResponseSerializer<[User], NSError> {
        return ResponseSerializer<User, NSError>.arrayResponseSerializer()
    }
}
```

#### Map responses

Map responses with `Alamofire` response serializers (`ResponseSerializer<T, NSError>`). There are standard JSON dictionary and array serializers over `ObjectMapper` providing easy mapping syntax including nested mapping (see `Alamofire+ObjectMapper`):

```swift
struct UsersRequest: NetworkRequest {
    ...
    var responseSerializer: ResponseSerializer<[User], NSError> {
        return ResponseSerializer<User, NSError>.arrayResponseSerializer()
    }
}
...
class User: Mappable {
    var userId: Int!
    var address: Address!

    init() {}
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        userId      <- map["id"]
        address     <- map["address"]
    }
}

class Address: Mappable {
    var street: String!

    init() {}
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        street      <- map["street"]
    }
}
```

You can also create your own serializers. See `ResponseSerializer` for more details.

#### Send request

```swift
let request = UsersRequest()
networkClient.sendRequest(request) { (users, error) in
    //Process response
}
```

### Offline mode caching

Offline mode caching for requests allows to use the last successful response when receiving request error. To use it, initialize network client with `offlineCacheManager` parameter:

```swift
let cacheManager = NetworkDefaultOfflineCacheManager(cacheName: "network_cache")
networkClient = NetworkDefaultClient(configuration: configuration, 
                                     offlineCacheManager: cacheManager)
```

Then specify the flag in requests:

```swift
struct UsersRequest: NetworkRequest {
    ...
    var useCache: Bool {
        return true
    }
}
```

Successful server responses will be cached automatically. If you cache a response and receive a network error next time, both the cached response and the error wil be received in `sendRequest` completion closure.

### Request mocks

To enable mocks for request you should configure network client with `useMocks` flag:

```swift
let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/", 
                                                useMocks: true)
```

Then implement mock itself by satisfying `NetworkRequestMock` protocol:

```swift
struct UsersMock: NetworkRequestMock {
    
    var responseDelay: NSTimeInterval {
        return 3
    }
    
    var mimeType: String {
        return "application/json"
    }
    
    func responseData() -> NSData? {
        //Return mock data
    }
}
```

Then specify mock object in request:

```swift
struct UsersRequest: NetworkRequest {
    ...
    var mockObject: NetworkRequestMock? {
        return UsersMock()
    }
}
```

### Client customization

#### Custom configurtion types

Create custom configuration structure if you need more information to initialize client:
```swift
public struct NetworkCustomConfiguration: NetworkConfiguration {
    
    public let baseURL: URLStringConvertible?
    public let useMocks: Bool
    public let debugMode: Bool
    public let completionQueue: dispatch_queue_t
    public let defaultTimeoutInterval: NSTimeInterval
    public let clientToken: String?
    
    public init(baseURL: URLStringConvertible? = nil,
                useMocks: Bool = true,
                debugMode: Bool = false,
                completionQueue: dispatch_queue_t = dispatch_get_main_queue(),
                defaultTimeoutInterval: NSTimeInterval = 60.0,
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

### Offline cache error processing

If you need to use offline mode cache in case of custom errors, you can subclass `NetworkDefaultClient` and override `shouldUseCachedResponseDataIfError` method.

## Requirements

Swift 2.2, xCode 7.3

## Author

e-Legion

## License

Flamingo is available under the MIT license. See the LICENSE file for more info.

## TODOs

1) Documentation

2) Carthage support

## P.S.

Pull requests are welcome 💪🏻
