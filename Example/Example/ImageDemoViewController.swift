//
//  ImageDemoViewController.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import UIKit
import Flamingo

class ImageDemoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image Demo"
        
        setupNetwork()
    }
    
    @IBAction func getRealImageTapped() {
        loadImageUsingMock(false)
    }
    
    @IBAction func userMockImageTapped() {
        loadImageUsingMock(true)
    }
    
    // MARK: Network
    
    fileprivate var networkClient: NetworkClient!
    
    fileprivate func setupNetwork() {
        let configuration = NetworkDefaultConfiguration(baseURL: nil, useMocks: true, debugMode: true)
        let cacheManager = NetworkDefaultOfflineCacheManager(cacheName: "network_cache")
        
        networkClient = NetworkDefaultClient(configuration: configuration, offlineCacheManager: cacheManager)
    }
    
    fileprivate func loadImageUsingMock(_ useMock: Bool) {
        if loadingIndicator.isAnimating {
            return
        }
        
        loadingIndicator.startAnimating()
        
        let request = ImageRequest(useMock: useMock)
        
        try! networkClient.sendRequest(request) { (image, error, context) in
            self.imageView.image = image
            
            self.loadingIndicator.stopAnimating()
        }
    }
}
