# Flamingo

## Description

Swift network manager. Based on Alamofire, ObjectMapper and Cache.

## Installation

With CocoaPods:

```
source 'https://github.com/elegion/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'Flamingo'
```

## Usage

#### Setup configuration

```
let configuration = NetworkConfiguration()
...
let configuration = NetworkConfiguration(baseURL: "http://jsonplaceholder.typicode.com/",
                                         debugMode: true)
...
let configuration = NetworkConfiguration(baseURL: "http://jsonplaceholder.typicode.com/",
                                         debugMode: true,
                                         completionQueue: dispatch_get_main_queue(),
                                         defaultTimeoutInterval: 10)
```

#### Setup network client

```
let configuration = NetworkConfiguration(baseURL: "http://jsonplaceholder.typicode.com/", debugMode: true)
let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")
let networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
```

#### Request protocol implementation example

```
struct UsersRequest: NetworkRequestPrototype {
    
    var URL: URLStringConvertible {
        return "users"
    }
    
    var baseURL: URLStringConvertible? {
        return "http://jsonplaceholder.typicode.com"
    }
    
    var useCache: Bool {
        return true
    }
    
    var mockObject: NetworkRequestMockPrototype? {
        return UsersMock()
    }
}
```

#### Mock protocol implementation example

```
struct UsersMock: NetworkRequestMockPrototype {
    
    var responseDelay: NSTimeInterval {
        return 3
    }
    
    var mimeType: String {
        return "application/json"
    }
    
    func responseData() -> NSData {
        var users = [User]()
        
        // ...
        
        return users.toNSData()
    }
}
```

#### Send request

```
let request = UsersRequest()
        
networkClient.sendRequest(request, responseSerializer: ResponseSerializer<User, NSError>.arrayResponseSerializer()) { (users, error) in
    let json = users?.toJSONString(true)
    
    // ...
}
```

## Requirements

Swift 2.2, xCode 7.3

## Author

e-Legion

## License

Flamingo is available under the MIT license. See the LICENSE file for more info.

## TODOs

0) Logo 🦄

1) Documentation

2) Carthage support

3) XML integration (add response serializers, etc.)

## P.S.

Pull requests are welcome 💪🏻
