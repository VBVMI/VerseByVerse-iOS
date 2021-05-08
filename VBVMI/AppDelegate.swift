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
import Firebase
import XCGLogger
import Reachability
import VimeoNetworking

let logger: XCGLogger = {
//    let logger = XCGLogger.default
//    logger.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    // NSLogger support
    // only log to the external window
    
    // Create a logger object with no destinations
    let log = XCGLogger(identifier: "versebyverse", includeDefaultDestinations: false)
    
    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "versebyverse.systemDestination")
    
    // Optionally set some configuration options
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    systemDestination.showDate = true
    
    // Add the destination to the logger
    log.add(destination: systemDestination)

    return log
}()

let VBVMIImageCache = AutoPurgingImageCache()
let MainContextChangedNotification = "UpdatedMainContext"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        logger.info("🍕Application will finish with options: \(launchOptions ?? [:])")
              
        URLCache.shared.removeAllCachedResponses()
        
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

        logger.info("🍕Creating Context Coordinator")
        let _ = ContextCoordinator.sharedInstance
        
        DispatchQueue.global(qos: .background).async {
            logger.info("🍕Dispatching the Downloads")
            APIDataManager.categories(completion: { (error) in
                if let error = error {
                    logger.error("🍕 Error downloading categories: \(error)")
                } else {
                    // download the studies
                    APIDataManager.core()
                    APIDataManager.latestLessons()
                }
            })
            APIDataManager.allTheChannels()
            APIDataManager.allTheCurriculums()

            let reachability = try? Reachability()
            if reachability?.connection == .wifi {
                APIDataManager.allTheArticles()
                APIDataManager.allTheAnswers()
            } else {
                APIDataManager.latestArticles()
                APIDataManager.latestAnswers()
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        logger.info("🍕Application did finish Launching with options: \(launchOptions ?? [:])")
        Theme.default.applyTheme()
        
        logger.info("🍕Creating Sound Manager")
        let _ = SoundManager.sharedInstance
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        logger.info("🍕Resign Active")
        APICoordinator.instance.stopPollingLivestream()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        logger.info("🍕Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        URLCache.shared.removeAllCachedResponses()
        SoundManager.sharedInstance.prepareToPlayAudio()
        logger.info("🍕Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        logger.info("🍕Active")
        APICoordinator.instance.startPollingLivestream()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        ContextCoordinator.sharedInstance.saveContext()
        logger.info("🍕Terminated")
    }

    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        application.ignoreSnapshotOnNextApplicationLaunch()
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        logger.info("🍕user activity: \(userActivity)")
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
            logger.info("🍕Error excluding \(myUrl.lastPathComponent) from backup \(error)");
        }
        
        return success
    }
    
    static func resourcesURL() -> URL? {
        if let url = _resourcesURL {
            return url
        }
        
        let fileManager = FileManager.default
        
        #if os(tvOS)
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        #else
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        #endif
        
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
            logger.info("🍕Couldn't get documents directory!")
        }
        
        return nil
    }
}

