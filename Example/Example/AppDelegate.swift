//
//  AppDelegate.swift
//  Example
//
//  Created by Георгий Касапиди on 16.05.16.
//  Copyright © 2016 ELN. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let jsonDemoController = JSONDemoViewController()
        jsonDemoController.tabBarItem = UITabBarItem(tabBarSystemItem: .Contacts, tag: 0)
        
        let imageDemoController = ImageDemoViewController()
        imageDemoController.tabBarItem = UITabBarItem(tabBarSystemItem: .Favorites, tag: 1)
        
        let tabsController = UITabBarController()
        tabsController.viewControllers = [UINavigationController(rootViewController: jsonDemoController),
                                          UINavigationController(rootViewController: imageDemoController)]
        
        window = UIWindow()
        window!.rootViewController = tabsController
        window!.makeKeyAndVisible()
        
        return true
    }
}
