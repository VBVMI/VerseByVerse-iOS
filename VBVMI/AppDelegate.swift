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
        
        let imageDownloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .FIFO, maximumActiveDownloads: 10, imageCache: VBVMIImageCache)
        UIImageView.af_sharedImageDownloader = imageDownloader

        setupPersistantStoreCoordinator()
        if let _ = self.persistentStoreCoordinator {
            setupManagedObjectContexts()
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                SoundManager.sharedInstance
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                APIDataManager.core()
                APIDataManager.latestArticles()
                APIDataManager.latestAnswers()
            }
        } else {
            return false
        }
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        Theme.Default.applyTheme()
        if let _ = self.persistentStoreCoordinator { } else {
            self.window?.rootViewController = UIViewController()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
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
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cactuslab.VBVMI" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("VBVMI", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    func setupPersistantStoreCoordinator() {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("VBVMIDatastore.sqlite")
        
        log.info("Database path: \(url)")
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            log.error("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            //While we're testing, lets just nuke existing data to stop peeps from getting mad about space
            let alert = UIAlertController(title: "Sorry", message: "You must delete and reinstall the application.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                abort()
            })
            alert.addAction(action)
            alert.show()
            return
        }
        
        self.persistentStoreCoordinator = coordinator
    }
    
    func setupManagedObjectContexts() {
        let coordinator = self.persistentStoreCoordinator
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        self.managedObjectContext = context
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator
        self.backgroundManagedObjectContext = backgroundContext
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.mergeMain(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.backgroundManagedObjectContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.mergeBackground(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.managedObjectContext)
    }

    var managedObjectContext: NSManagedObjectContext!
    var backgroundManagedObjectContext: NSManagedObjectContext!
    
    func mergeMain(notification: NSNotification) {
//        log.info("Merging Main context")
        managedObjectContext.performBlock { () -> Void in
            self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
        }
        
    }
    
    func mergeBackground(notification: NSNotification) {
        backgroundManagedObjectContext.performBlock { () -> Void in
//            log.info("Merging Background context")
            self.backgroundManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    // MARK: - Core Data Saving support

    func saveContext () {
        managedObjectContext.performBlock { () -> Void in
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
    }

    private static var _resourcesURL: NSURL? = nil
    
    static func resourcesURL() -> NSURL? {
        if let url = _resourcesURL {
            return url
        }
        
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        if let documentDirectory: NSURL = urls.first {
            // This is where the database should be in the documents directory
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

