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
    
    lazy var applicationSupportDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cactuslab.VBVMI" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "VBVMI", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    
    override fileprivate init() {
        super.init()
        
        //Migrate from the old directory to the new one
        moveDataStore()
        
        setupPersistantStoreCoordinator()
        setupManagedObjectContexts()
    }
    
    /**
     Moving the datastore is important due to a mistake made with the first version. We actually want to store the core data store in ApplicationSupport not in Documents
     */
    fileprivate func moveDataStore() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsFolder = urls[urls.count-1]
        
        if FileManager.default.fileExists(atPath: documentsFolder.appendingPathComponent("VBVMIDatastore.sqlite").path) {
            let applicationSupportFolder = applicationSupportDirectory
            
            if !FileManager.default.fileExists(atPath: applicationSupportFolder.path) {
                let _ = try? FileManager.default.createDirectory(at: applicationSupportFolder, withIntermediateDirectories: true, attributes: nil)
            }
            
            do {
                try FileManager.default.moveItem(at: documentsFolder.appendingPathComponent("VBVMIDatastore.sqlite"), to: applicationSupportFolder.appendingPathComponent("VBVMIDatastore.sqlite"))
            } catch let error {
                logger.error("Tried to move file:\(error)")
            }
            do {
                try FileManager.default.moveItem(at: documentsFolder.appendingPathComponent("VBVMIDatastore.sqlite-shm"), to: applicationSupportFolder.appendingPathComponent("VBVMIDatastore.sqlite-shm"))
            } catch let error {
                logger.error("Tried to move file:\(error)")
            }
            do {
                try FileManager.default.moveItem(at: documentsFolder.appendingPathComponent("VBVMIDatastore.sqlite-wal"), to: applicationSupportFolder.appendingPathComponent("VBVMIDatastore.sqlite-wal"))
            } catch let error {
                logger.error("Tried to move file:\(error)")
            }
        }
    }
    
    fileprivate func deleteDataStore() {
        let applicationSupportFolder = applicationSupportDirectory
        do {
            try FileManager.default.removeItem(at: applicationSupportFolder.appendingPathComponent("VBVMIDatastore.sqlite"))
        } catch let error {
            logger.error("Tried to move file:\(error)")
        }
        do {
            try FileManager.default.removeItem(at: applicationSupportFolder.appendingPathComponent("VBVMIDatastore.sqlite-shm"))
        } catch let error {
            logger.error("Tried to move file:\(error)")
        }
        do {
            try FileManager.default.removeItem(at: applicationSupportFolder.appendingPathComponent("VBVMIDatastore.sqlite-wal"))
        } catch let error {
            logger.error("Tried to move file:\(error)")
        }
    }
    

    func setupPersistantStoreCoordinator() {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = applicationSupportDirectory.appendingPathComponent("VBVMIDatastore.sqlite")
        
        if !FileManager.default.fileExists(atPath: applicationSupportDirectory.path) {
            let _ = try? FileManager.default.createDirectory(at: applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        //logger.info("Database path: \(url)")
        do {
            #if os(tvOS)
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
            #else
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
            #endif
            
        } catch let error {
            
            logger.error("Error building store \(error)")
            
            //Blow away the data store because it is probably corrupted or I was being a total noob and didn't set up the migrations properly
            deleteDataStore()
            setupPersistantStoreCoordinator()
            return
        }
        
        self.persistentStoreCoordinator = coordinator
    }
    
    func setupManagedObjectContexts() {
        let coordinator = self.persistentStoreCoordinator
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        self.managedObjectContext = context
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator
        self.backgroundManagedObjectContext = backgroundContext
        
        NotificationCenter.default.addObserver(self, selector: #selector(mergeMain(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.backgroundManagedObjectContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mergeBackground(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.managedObjectContext)
        
        migrateData(backgroundContext)
    }
    

    
    func mergeMain(_ notification: Notification) {
        //        logger.info("Merging Main context")
        managedObjectContext.perform { () -> Void in
            self.managedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
        
    }
    
    func mergeBackground(_ notification: Notification) {
        backgroundManagedObjectContext.perform { () -> Void in
            //            logger.info("Merging Background context")
            self.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func saveContext () {
        managedObjectContext.perform { () -> Void in
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
    
    
    fileprivate func migrateData(_ context: NSManagedObjectContext) {
        if !UserDefaults.standard.bool(forKey: "CompletedCountMigration") {
            context.perform({ 
                let studies : [Study] = Study.findAll(context)
                
                studies.forEach({ (study) in
                    let predicate = NSPredicate(format: "%K == %@", LessonAttributes.studyIdentifier.rawValue, study.identifier)
                    let lessons: [Lesson] = Lesson.findAllWithPredicate(predicate, context: context)
                    
                    let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
                        return lesson.completed ? value + 1 : value
                    })
                    study.lessonsCompleted = Int32(lessonsCompleted)
                })
                
                let _ = try? context.save()
                
                UserDefaults.standard.set(true, forKey: "CompletedCountMigration")
                UserDefaults.standard.synchronize()
            })
        }
    }
}
