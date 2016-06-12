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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "JSON Demo"
        
        textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
        
        setupNetwork()
    }
    
    @IBAction func getRealDataTapped() {
        loadUsersUsingMock(false)
    }
    
    @IBAction func useMockDataTapped() {
        loadUsersUsingMock(true)
    }
    
    // MARK: Network
    
    private var networkClient: NetworkClientPrototype!
    
    private func setupNetwork() {
        let configuration = NetworkConfiguration(baseURL: "http://jsonplaceholder.typicode.com/", debugMode: true)
        let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")
        
        networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
    }
    
    private func loadUsersUsingMock(useMock: Bool) {
        if loadingIndicator.isAnimating() {
            return
        }
        
        loadingIndicator.startAnimating()
        
        let request = UsersRequest(useMock: useMock)
        
        networkClient.sendRequest(request, responseSerializer: ResponseSerializer<User, NSError>.arrayResponseSerializer()) { (users, error) in
            let json = users?.toJSONString(true)
            
            self.textView.text = json
            
            self.loadingIndicator.stopAnimating()
        }
    }
}
