//
//  AppDelegate.swift
//  DUI Instant Attorney
//
//  Created by mobile developer on 2017. 06. 05..
//  Copyright © 2017. Balazs Benjamin. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import GoogleMaps
import OneSignal
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBoqcEKVc3mOVjNEuEhznE76h5SV8Zxe9o")

        FirebaseApp.configure()
        
        IQKeyboardManager.sharedManager().enable = true
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        /*
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            //FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        */

        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "1da67ee1-49c4-416a-b812-02a1aeb68d06", handleNotificationReceived: { (notification) in
            //print("Received Notification - \(notification?.payload.notificationID)")
        }, handleNotificationAction: { (result) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let window = self.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                
                if currentController is MessageViewController {
                    
                } else {
                    let messageViewController = storyboard.instantiateViewController(withIdentifier: "messageView") as! MessageViewController
                    //self.present(messageViewController, animated:true, completion:nil)
                    let navigationController = application.windows[0].rootViewController as! UINavigationController
                    
                    navigationController.pushViewController(messageViewController,  animated: true)
                }
            } else {
                /*
                let initialViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "initalViewController") as UIViewController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
                
                let messageViewController = storyboard.instantiateViewController(withIdentifier: "messageView") as! MessageViewController
                let navigationController = initialViewController as! UINavigationController
                navigationController.pushViewController(messageViewController,  animated: true)
                 */
            }
        }, settings: [kOSSettingsKeyAutoPrompt : true, kOSSettingsKeyInAppAlerts : false])
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        OneSignal.idsAvailable({ (userId, pushToken) in
            print("UserId:%@", userId!);
            if (pushToken != nil) {
                NSLog("Sending Test Noification to this device now");
                //OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [userId]]);
                
                UserDefaults.standard.set(userId, forKey: "OneSignalId")
                
                if Auth.auth().currentUser != nil {
                    let uid = Auth.auth().currentUser!.uid
                    let ref = Database.database().reference().child("users/\(uid)/OneSignalId")
                    ref.setValue(userId!)
                }
            }
        })
        
        return true
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

