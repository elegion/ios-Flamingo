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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let jsonDemoController = JSONDemoViewController(nibName: "JSONDemoViewController", bundle: nil)
        jsonDemoController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        let imageDemoController = ImageDemoViewController(nibName: "ImageDemoViewController", bundle: nil)
        imageDemoController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        let tabsController = UITabBarController()
        tabsController.viewControllers = [UINavigationController(rootViewController: jsonDemoController),
                                          UINavigationController(rootViewController: imageDemoController)]
        
        window = ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) ? UIWindow() : UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = tabsController
        window!.makeKeyAndVisible()
        
        return true
    }
}
