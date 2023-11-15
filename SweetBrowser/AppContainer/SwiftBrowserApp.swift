//
//  SwiftBrowserApp.swift
//  SwiftBrowser
//
//  Created by yangjian on 2023/9/15.
//

import SwiftUI
import UIKit
import FBSDKCoreKit

@main
struct SwiftBrowserApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Store())
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        
        var window: UIWindow?
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
            )
            return true
        }
        
        func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }
        
        func applicationWillEnterForeground(_ application: UIApplication) {
            
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            
        }
    }
}
