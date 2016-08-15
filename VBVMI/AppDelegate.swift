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
#if DEBUG
import XCGLoggerNSLoggerConnector
import NSLogger
#endif

let log: XCGLogger = {
    let log = XCGLogger.defaultInstance()
    log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Debug)
    log.xcodeColorsEnabled = true
    // NSLogger support
    // only log to the external window
    #if DEBUG
    LoggerSetOptions(LoggerGetDefaultLogger(), UInt32( kLoggerOption_BufferLogsUntilConnection | kLoggerOption_BrowseBonjour | kLoggerOption_BrowseOnlyLocalDomain ))
    LoggerStart(LoggerGetDefaultLogger())
    log.addLogDestination(XCGNSLoggerLogDestination(owner: log, identifier: "nslogger.identifier"))
    #endif
    return log
}()

let VBVMIImageCache = AutoPurgingImageCache()
let MainContextChangedNotification = "UpdatedMainContext"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
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
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        if let originURL = urls.first {
            let oldResources = originURL.URLByAppendingPathComponent("resources")
            if fileManager.fileExistsAtPath(oldResources.path!) {
                let destinationURL = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first?.URLByAppendingPathComponent("resources")
                if let destinationURL = destinationURL {
                    let _ = try? fileManager.moveItemAtURL(oldResources, toURL: destinationURL)
                }
            }
        }
        
        
        
        let imageDownloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .FIFO, maximumActiveDownloads: 10, imageCache: VBVMIImageCache)
        UIImageView.af_sharedImageDownloader = imageDownloader

        let _ = ContextCoordinator.sharedInstance
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SoundManager.sharedInstance
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            APIDataManager.core()
            APIDataManager.allTheChannels()
            
            let reachability: Reachability
            do {
                reachability = try Reachability.reachabilityForInternetConnection()
            } catch {
                print("Unable to create Reachability")
                return
            }
            if reachability.isReachableViaWiFi() {
                APIDataManager.allTheArticles()
                APIDataManager.allTheAnswers()
            } else {
                APIDataManager.latestArticles()
                APIDataManager.latestAnswers()
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        Theme.Default.applyTheme()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("Resign Active")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("Foreground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Active")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        ContextCoordinator.sharedInstance.saveContext()
        print("Terminated")
    }

    
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        application.ignoreSnapshotOnNextApplicationLaunch()
        return true
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, didUpdateUserActivity userActivity: NSUserActivity) {
        print("user activity: \(userActivity)")
    }
    
    private static var _resourcesURL: NSURL? = nil
    
    private static func addSkipBackupAttributeToItemAtURL(filePath:String) -> Bool
    {
        let URL:NSURL = NSURL.fileURLWithPath(filePath)
        
        assert(NSFileManager.defaultManager().fileExistsAtPath(filePath), "File \(filePath) does not exist")
        
        var success: Bool
        do {
            try URL.setResourceValue(true, forKey:NSURLIsExcludedFromBackupKey)
            success = true
        } catch let error as NSError {
            success = false
            print("Error excluding \(URL.lastPathComponent) from backup \(error)");
        }
        
        return success
    }
    
    static func resourcesURL() -> NSURL? {
        if let url = _resourcesURL {
            return url
        }
        
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        
        if let documentDirectory: NSURL = urls.first {
            // This is where the database should be in the application support directory
            let rootURL = documentDirectory.URLByAppendingPathComponent("resources")
            if let path = rootURL.path where !fileManager.fileExistsAtPath(path) {
                do {
                    try fileManager.createDirectoryAtURL(rootURL, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    log.error("Error creating resources directory: \(error)")
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

