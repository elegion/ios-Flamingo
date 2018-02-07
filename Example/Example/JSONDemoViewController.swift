//
//  JSONDemoViewController.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import UIKit
import Flamingo

class JSONDemoViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "JSON Demo"
        
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        setupNetwork()
    }
    
    @IBAction func getRealDataTapped() {
        loadUsersUsingMock(false)
    }
    
    @IBAction func useMockDataTapped() {
        loadUsersUsingMock(true)
    }
    
    // MARK: Network
    
    fileprivate var networkClient: NetworkClient!
    
    fileprivate func setupNetwork() {
        let configuration = NetworkDefaultConfiguration(baseURL: "http://jsonplaceholder.typicode.com/")
        
        networkClient = NetworkDefaultClient(configuration: configuration, session: .shared)
    }
    
    fileprivate func loadUsersUsingMock(_ useMock: Bool) {
        if loadingIndicator.isAnimating {
            return
        }
        
        loadingIndicator.startAnimating()
        
        let request = UsersRequest(useMock: useMock)
        
        networkClient.sendRequest(request) {
            (result, context) in
            
            switch result {
            case .success(let users):
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let encoded = try? encoder.encode(users)
                self.textView.text = String(data: encoded!, encoding: .utf8)
            case .error:
                break
            }
            
            self.loadingIndicator.stopAnimating()
        }
    }
}
