//
//  JSONDemoViewController.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import UIKit
import Alamofire
import Flamingo

class JSONDemoViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var networkClient: NetworkClientPrototype!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "JSON Demo"
        
        let configuration = NetworkConfiguration(baseURL: "http://jsonplaceholder.typicode.com/", debugMode: true)
        let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")
        
        networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
        
        textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
    }
    
    @IBAction func getRealDataTapped() {
        loadUsersWithMock(nil)
    }
    
    @IBAction func useMockDataTapped() {
        loadUsersWithMock(UsersMock())
    }
    
    private func loadUsersWithMock(mockObject: NetworkRequestMockPrototype?) {
        if loadingIndicator.isAnimating() {
            return
        }
        
        loadingIndicator.startAnimating()
        
        let requestInfo = NetworkRequest(URL: "users")
        let repsonseSerializer = AlamofireObjectMapperFactory<User>().arrayResponseSerializer()
        let networkCommand = NetworkCommand(requestInfo: requestInfo, responseSerializer: repsonseSerializer) { (users, error) in
            let json = users?.toJSONString(true)
            
            self.textView.text = json
            
            self.loadingIndicator.stopAnimating()
        }
        
        networkClient.executeCommand(networkCommand, useCache: true, mockObject: mockObject)
    }
}
