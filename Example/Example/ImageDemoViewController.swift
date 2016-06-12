//
//  ImageDemoViewController.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
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
    
    private var networkClient: NetworkClientPrototype!
    
    private func setupNetwork() {
        let configuration = NetworkConfiguration(baseURL: nil, debugMode: true, defaultTimeoutInterval: 5)
        let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")
        
        networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
    }
    
    private func loadImageUsingMock(useMock: Bool) {
        if loadingIndicator.isAnimating() {
            return
        }
        
        loadingIndicator.startAnimating()
        
        let request = ImageRequest(useMock: useMock)
        
        networkClient.sendRequest(request, responseSerializer: Request.imageResponseSerializer()) { (image, error) in
            self.imageView.image = image
            
            self.loadingIndicator.stopAnimating()
        }
    }
}
