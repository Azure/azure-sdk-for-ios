//
//  AppDelegate.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AzureData.configure(withPermissionMode: .all)

        return true
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        ((window?.rootViewController as? UINavigationController)?.topViewController as? DatabaseTableViewController)?.refreshData()
    }
}
