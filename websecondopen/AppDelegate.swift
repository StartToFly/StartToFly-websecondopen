//
//  AppDelegate.swift
//  websecondopen
//
//  Created by 冯笑 on 2021/4/26.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 12.0, *) {
            MSReuseWebView.msChangeHandlesURLScheme()
        }
        MSWebViewReusePool.shared.prepareReuseWebView()
        let cactusH5App =  Bundle.main.path(forResource: "cactus-h5-app", ofType: "zip" )
        let cactusH5ForAppStudent =  Bundle.main.path(forResource: "cactus-h5-for-app-student", ofType: "zip" )

        let cactusH5AppUnZipPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/MSPWebSecondOpenComponent/cactus-h5-app"
        let cactusH5ForAppStudentUnZipPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/MSPWebSecondOpenComponent/cactus-h5-for-app-student"

        MSZipArchiveMananger.shared.unzipFile(atPath: cactusH5App!, toDestination: cactusH5AppUnZipPath) { (entry,zipInfo,entryNumber,total) in
            
        } completion: { (path, success, error) in
    
        }
        
        MSZipArchiveMananger.shared.unzipFile(atPath: cactusH5ForAppStudent!, toDestination: cactusH5ForAppStudentUnZipPath) { (entry,zipInfo,entryNumber,total) in
            
        } completion: { (path, success, error) in
    
        }
        
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
