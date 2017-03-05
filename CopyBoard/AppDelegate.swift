//
//  AppDelegate.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: NotesViewController())
        navigationController.view.backgroundColor = AppColors.mainBackground
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        DBManager.configDB()
        
        application.registerForRemoteNotifications()
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        if !AppSettings.shared.appSetup {
            CloudKitManager.shared.asyncFromCloud()
            AppSettings.shared.keyboardFilterColor = [0, 1, 2, 3, 4, 5]
        } else {
            CloudKitManager.shared.syncOfflineDataFromCloud()
        }
        
        CloudKitManager.shared.createSubscription()
        
        if #available(iOS 9.0, *) {
            self.configureDynamicShortcuts()
        }
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        CloudKitManager.shared.syncOfflineDataFromCloud()
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

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        CloudKitManager.shared.handleNotification(userInfo: userInfo)
    }

}

@available(iOS 9.0, *)
extension AppDelegate {
    @objc(application:performActionForShortcutItem:completionHandler:) func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        QuickActionDispatcher().dispatch(shortcutItem, completion: completionHandler)
    }
    
    fileprivate func configureDynamicShortcuts() {
        let createItem = UIApplicationShortcutItem(
            type: QuickActionType.create.rawValue,
            localizedTitle: Localized("create"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(type: .add),
            userInfo: nil)
        
        
        let searchItem = UIApplicationShortcutItem(
            type: QuickActionType.search.rawValue,
            localizedTitle: Localized("search"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(type: .search),
            userInfo: nil)
        
        let settingsIcon = UIApplicationShortcutIcon(templateImageName: "shortcutsSetting")
        let settingItem = UIApplicationShortcutItem(
            type: QuickActionType.setting.rawValue,
            localizedTitle: Localized("setting"),
            localizedSubtitle: "",
            icon: settingsIcon,
            userInfo: nil)
        
        UIApplication.shared.shortcutItems =
            [ createItem, searchItem, settingItem]
    }
    
}
