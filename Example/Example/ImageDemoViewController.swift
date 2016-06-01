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
    
    private var networkClient: NetworkClientPrototype!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image Demo"
        
        let configuration = NetworkConfiguration(baseURL: nil,
                                                 debugMode: true,
                                                 completionQueue: dispatch_get_main_queue(),
                                                 defaultTimeoutInterval: 5)
        let cacheManager = NetworkDefaultCacheManager(cacheName: "network_cache")
        
        networkClient = NetworkClient(configuration: configuration, cacheManager: cacheManager)
    }
    
    @IBAction func getRealImageTapped() {
        loadImageWithMock(nil)
    }
    
    @IBAction func userMockImageTapped() {
        loadImageWithMock(ImageMock())
    }
    
    private func loadImageWithMock(mockObject: NetworkRequestMockPrototype?) {
        if loadingIndicator.isAnimating() {
            return
        }
        
        loadingIndicator.startAnimating()
        
        let requestInfo = NetworkRequest(URL: "http://lorempixel.com/320/480?q=\(arc4random())")
        let responseSerializer = Request.imageResponseSerializer()
        let networkCommand = NetworkCommand(requestInfo: requestInfo, responseSerializer: responseSerializer) { (image, error) in
            self.imageView.image = image
            
            self.loadingIndicator.stopAnimating()
        }
        
        networkClient.executeCommand(networkCommand, useCache: true, mockObject: mockObject)
    }
}
