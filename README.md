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
let configuration = NetworkConfiguration(baseURL: nil, // default - nil
                                         debugMode: true, // default - false
                                         completionQueue: dispatch_get_main_queue(), // default - main queue
                                         defaultTimeoutInterval: 5) // default - 60
```

#### Setup request

```
let request = NetworkRequest(URL: "http://someurl.com/api")
...

let request = NetworkRequest(URL: "http://someurl.com/api", method: .GET)
...

let request = NetworkRequest(URL: "http://someurl.com/api", // required
                             method: .GET, // optional, default - GET
                             parametersEncoding: .URL, // optional, default - URL
                             parameters: ["key": "value"], // optional, default - nil
                             headers: ["key" : "value"], // optional, default - nil
                             timeoutInterval: 15, // optional, default - nil
                             completionQueue: dispatch_get_main_queue()) // optional, default - nil
```

#### JSON example

```
let configuration = NetworkConfiguration(baseURL: "http://jsonplaceholder.typicode.com/", debugMode: true)
let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")

let networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
```

```
let requestInfo = NetworkRequest(URL: "users")
let repsonseSerializer = AlamofireObjectMapperFactory<User>().arrayResponseSerializer()
let networkCommand = NetworkCommand(requestInfo: requestInfo, responseSerializer: repsonseSerializer) { (users, error) in
    let json = users?.toJSONString(true)
    
    // do some with JSON
}

networkClient.executeCommand(networkCommand, useCache: true, mockObject: nil)
```

#### Image example

```
let configuration = NetworkConfiguration(baseURL: nil, debugMode: true)
let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")

let networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
```

```
let requestInfo = NetworkRequest(URL: "http://lorempixel.com/320/480?q=\(arc4random())")
let responseSerializer = Request.imageResponseSerializer()
let networkCommand = NetworkCommand(requestInfo: requestInfo, responseSerializer: responseSerializer) { (image, error) in
    // do some with image
}

networkClient.executeCommand(networkCommand, useCache: true, mockObject: nil)
```

#### Mock example

```
class ImageMock: NetworkRequestMockPrototype {
    
    var responseDelay: NSTimeInterval {
        return 2
    }
    
    var mimeType: String {
        return "image/jpeg"
    }
    
    func responseData() -> NSData {
        let image = UIImage(named: "demo_image.jpeg")!
        
        return UIImagePNGRepresentation(image)!
    }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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
