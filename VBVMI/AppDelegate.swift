//
//  AppDelegate.swift
//  VBVMI
//
//  Created by Thomas Carey on 31/01/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import Fabric
import Crashlytics
import XCGLogger
import ReachabilitySwift

let logger: XCGLogger = {
    let logger = XCGLogger.default
    logger.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    // NSLogger support
    // only log to the external window
    return logger
}()

let VBVMIImageCache = AutoPurgingImageCache()
let MainContextChangedNotification = "UpdatedMainContext"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setenv("XcodeColors", "YES", 0);
        //Fabric.sharedSDK().debug = true
        
//        DDTTYLogger.sharedInstance().colorsEnabled = true
//        DDLog.addLogger(DDTTYLogger.sharedInstance(), withLevel: .Verbose)
        //DDLog.addLogger(DDASLLogger.sharedInstance(), withLevel: .Warning)
//        DDLog.addLogger(CrashlyticsLogger.sharedInstance(), withLevel: .Warning)
        
//        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
//        fileLogger.rollingFrequency = 60*60*24  // 24 hours
//        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
//        DDLog.addLogger(fileLogger)
//        DDTTYLogger.sharedInstance().setForegroundColor(UIColor(red:0.066667, green:0.662745, blue:0.054902, alpha:1.0), backgroundColor: nil, forFlag: DDLogFlag.Info)
        
        
        //Move all of the old resources to the Application support directory
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let originURL = urls.first {
            let oldResources = originURL.appendingPathComponent("resources")
            if fileManager.fileExists(atPath: oldResources.path) {
                let destinationURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("resources")
                if let destinationURL = destinationURL {
                    let _ = try? fileManager.moveItem(at: oldResources, to: destinationURL)
                }
            }
        }
        
        
        
        let imageDownloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .fifo, maximumActiveDownloads: 10, imageCache: VBVMIImageCache)
        UIImageView.af_sharedImageDownloader = imageDownloader

        let _ = ContextCoordinator.sharedInstance
        
        DispatchQueue.main.async { () -> Void in
            let _ = SoundManager.sharedInstance
        }
        
        DispatchQueue.global(qos: .background).async {
            APIDataManager.core()
            APIDataManager.allTheChannels()
            
            let reachability = Reachability()
            if reachability?.isReachableViaWiFi == true {
                APIDataManager.allTheArticles()
                APIDataManager.allTheAnswers()
            } else {
                APIDataManager.latestArticles()
                APIDataManager.latestAnswers()
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        Theme.default.applyTheme()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("Resign Active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        ContextCoordinator.sharedInstance.saveContext()
        print("Terminated")
    }

    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        application.ignoreSnapshotOnNextApplicationLaunch()
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("user activity: \(userActivity)")
    }
    
    fileprivate static var _resourcesURL: URL? = nil
    
    fileprivate static func addSkipBackupAttributeToItemAtURL(_ filePath:String) -> Bool
    {
        let myUrl = URL(fileURLWithPath: filePath)
        
        assert(FileManager.default.fileExists(atPath: filePath), "File \(filePath) does not exist")
        
        var success: Bool
        do {
            try (myUrl as NSURL).setResourceValue(true, forKey:URLResourceKey.isExcludedFromBackupKey)
            success = true
        } catch let error as NSError {
            success = false
            print("Error excluding \(myUrl.lastPathComponent) from backup \(error)");
        }
        
        return success
    }
    
    static func resourcesURL() -> URL? {
        if let url = _resourcesURL {
            return url
        }
        
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        if let documentDirectory: URL = urls.first {
            // This is where the database should be in the application support directory
            let rootURL = documentDirectory.appendingPathComponent("resources")
            let path = rootURL.path
            if !fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    logger.error("Error creating resources directory: \(error)")
                    return nil
                }
                
            }
            
            _resourcesURL = rootURL
            return rootURL
        
        } else {
            print("Couldn't get documents directory!")
        }
        
        return nil
    }
}

