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
        let jsonDemoController = JSONDemoViewController(nibName: "JSONDemoViewController", bundle: nil)
        jsonDemoController.tabBarItem = UITabBarItem(tabBarSystemItem: .Contacts, tag: 0)
        
        let imageDemoController = ImageDemoViewController(nibName: "ImageDemoViewController", bundle: nil)
        imageDemoController.tabBarItem = UITabBarItem(tabBarSystemItem: .Favorites, tag: 1)
        
        let tabsController = UITabBarController()
        tabsController.viewControllers = [UINavigationController(rootViewController: jsonDemoController),
                                          UINavigationController(rootViewController: imageDemoController)]
        
        window = NSProcessInfo.processInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) ? UIWindow() : UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = tabsController
        window!.makeKeyAndVisible()
        
        return true
    }
}
