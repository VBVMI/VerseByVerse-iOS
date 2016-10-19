//
//  AppDelegate.swift
//  VBVMI-tvOS
//
//  Created by Thomas Carey on 17/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import XCGLogger
import AlamofireImage

let logger: XCGLogger = {
    let logger = XCGLogger.default
    logger.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    // NSLogger support
    // only log to the external window
    return logger
}()

let VBVMIImageCache = AutoPurgingImageCache()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let imageDownloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .fifo, maximumActiveDownloads: 10, imageCache: VBVMIImageCache)
        UIImageView.af_sharedImageDownloader = imageDownloader
        
        let _ = ContextCoordinator.sharedInstance
        
        DispatchQueue.global(qos: .background).async {
            APIDataManager.core()
            APIDataManager.allTheChannels()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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

    fileprivate static var _resourcesURL: URL? = nil
    
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

