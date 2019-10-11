//
//  AppDelegate.swift
//  PopdeemSwift
//
//  Created by Popdeem on 06/03/2019.
//  Copyright © 2019 Popdeem. All rights reserved.
//

import PopdeemSDK
import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        // KRISPY KREME COLOURS
        // #CB1530 - RED
        // #0A683A - GREEN
        // #F0B138 - YELLOW
        
        
        PopdeemSDK.setThirdPartyUserToken("tokenstring")
        
        //PopdeemSDK.logMoment("post_payment")


        
        PopdeemSDK.withAPIKey("e934194f-cf4d-4b79-8526-9ccbbc06d0c9", env:PDEnv.production)
        //PopdeemSDK.withAPIKey("26eb2fcb-06e5-4976-bff4-88c30cc58f58", env:PDEnvProduction)
    
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], for: UIControl.State.normal)
        
        
        PopdeemSDK.enableSocialLogin(withNumberOfPrompts: 100)
        PopdeemSDK.setUpThemeFile("theme")
        
        PopdeemSDK.register(forPushNotificationsApplication: application)
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        

        return true
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PopdeemSDK.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PopdeemSDK.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // if ([[userInfo objectForKey:@"sender"] isEqualToString:@"popdeem"]) {
        //if (userinfo["sender"] == "popdeem") {
            PopdeemSDK.handleRemoteNotification(userInfo)
            return
      //  }
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = ApplicationDelegate.shared.application(app, open: url, sourceApplication:
            options[.sourceApplication] as? String, annotation: options[.annotation])
        
        // Add any custom logic here.
        if handled {return handled}
        
        if PopdeemSDK.application(app, canOpen: url, options: options) {
            return PopdeemSDK.application(app, open: url, options: (options[.sourceApplication] as? [String : Any])!)
        }
        return false
        
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

