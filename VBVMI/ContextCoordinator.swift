//
//  ContextCoordinator.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/08/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData

class ContextCoordinator: NSObject {
    
    static let sharedInstance = ContextCoordinator()
    
    var managedObjectContext: NSManagedObjectContext!
    var backgroundManagedObjectContext: NSManagedObjectContext!
    
    lazy var applicationSupportDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cactuslab.VBVMI" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("VBVMI", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    
    override private init() {
        super.init()
        
        //Migrate from the old directory to the new one
        moveDataStore()
        
        setupPersistantStoreCoordinator()
        setupManagedObjectContexts()
    }
    
    /**
     Moving the datastore is important due to a mistake made with the first version. We actually want to store the core data store in ApplicationSupport not in Documents
     */
    private func moveDataStore() {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsFolder = urls[urls.count-1]
        
        if NSFileManager.defaultManager().fileExistsAtPath(documentsFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite")!.path!) {
            let applicationSupportFolder = applicationSupportDirectory
            
            if !NSFileManager.defaultManager().fileExistsAtPath(applicationSupportFolder.path!) {
                let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(applicationSupportFolder, withIntermediateDirectories: true, attributes: nil)
            }
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(documentsFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite")!, toURL: applicationSupportFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite")!)
            } catch let error {
                log.error("Tried to move file:\(error)")
            }
            do {
                try NSFileManager.defaultManager().moveItemAtURL(documentsFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite-shm")!, toURL: applicationSupportFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite-shm")!)
            } catch let error {
                log.error("Tried to move file:\(error)")
            }
            do {
                try NSFileManager.defaultManager().moveItemAtURL(documentsFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite-wal")!, toURL: applicationSupportFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite-wal")!)
            } catch let error {
                log.error("Tried to move file:\(error)")
            }
        }
    }
    
    private func deleteDataStore() {
        let applicationSupportFolder = applicationSupportDirectory
        do {
            try NSFileManager.defaultManager().removeItemAtURL(applicationSupportFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite")!)
        } catch let error {
            log.error("Tried to move file:\(error)")
        }
        do {
            try NSFileManager.defaultManager().removeItemAtURL(applicationSupportFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite-shm")!)
        } catch let error {
            log.error("Tried to move file:\(error)")
        }
        do {
            try NSFileManager.defaultManager().removeItemAtURL(applicationSupportFolder.URLByAppendingPathComponent("VBVMIDatastore.sqlite-wal")!)
        } catch let error {
            log.error("Tried to move file:\(error)")
        }
    }
    

    func setupPersistantStoreCoordinator() {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = applicationSupportDirectory.URLByAppendingPathComponent("VBVMIDatastore.sqlite")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(applicationSupportDirectory.path!) {
            let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        //log.info("Database path: \(url)")
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch let error {
            
            log.error("Error building store \(error)")
            
            //Blow away the data store because it is probably corrupted or I was being a total noob and didn't set up the migrations properly
            deleteDataStore()
            setupPersistantStoreCoordinator()
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(mergeMain(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.backgroundManagedObjectContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(mergeBackground(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.managedObjectContext)
    }
    

    
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
}
