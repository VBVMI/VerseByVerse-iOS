//
//  NSManagedObject+Extensions.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObject {
    
    class func VB_entityName() -> String {
        return NSStringFromClass(self)
    }
    
    class func entityDescriptionInContext(context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(VB_entityName(), inManagedObjectContext: context)
    }
    
    class func findFirstOrCreate(predicate: NSPredicate, context: NSManagedObjectContext) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: VB_entityName())
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescriptionInContext(context)
        
        var results = [AnyObject]()
        context.performBlockAndWait({ () -> Void in
            do {
                results = try context.executeFetchRequest(fetchRequest)
            } catch let error {
                log.error("Error executing fetch: \(error)")
            }
        })
        
        if let result = results.first as? NSManagedObject {
            return result
        }
        
        guard let entityDesciption = entityDescriptionInContext(context) else { return nil }
        var object: NSManagedObject?
        context.performBlockAndWait { () -> Void in
            object = self.init(entity: entityDesciption, insertIntoManagedObjectContext: context)
        }
        return object
    }
    
    class func findFirstOrCreateWithDictionary(dict: [String: String], context: NSManagedObjectContext) -> NSManagedObject? {
        return findFirstOrCreate(NSPredicate.predicateWithDictionary(dict), context: context)
    }
    
    class func findFirstWithDictionary(dict: [String: String], context: NSManagedObjectContext) -> NSManagedObject? {
        let predicate = NSPredicate.predicateWithDictionary(dict)
        return findFirstWithPredicate(predicate, context: context)
    }
    
    class func findFirst<T: NSManagedObject>(context: NSManagedObjectContext) -> T? {
        let fetchRequest = NSFetchRequest(entityName: VB_entityName())
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.executeFetchRequest(fetchRequest)
        return result?.first as? T
    }
    
    class func findFirstWithPredicate<T: NSManagedObject>(predicate: NSPredicate, context: NSManagedObjectContext) -> T? {
        
        let fetchRequest = NSFetchRequest(entityName: VB_entityName())
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.executeFetchRequest(fetchRequest)
        return result?.first as? T
    }
    
    class func withIdentifier<T: NSManagedObject>(identifier: NSManagedObjectID, context: NSManagedObjectContext) throws -> T? {
        return try context.existingObjectWithID(identifier) as? T
    }
    
    class func findAllWithDictionary(dict: [String: String], context: NSManagedObjectContext) -> [NSManagedObject] {
        let predicate = NSPredicate.predicateWithDictionary(dict)
        
        return findAllWithPredicate(predicate, context: context)
    }
    
    class func findAllWithPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName: VB_entityName())
        fetchRequest.predicate = predicate
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.executeFetchRequest(fetchRequest)
        return result as? [NSManagedObject] ?? []
    }
    
    class func findAll(context: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: VB_entityName())
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.executeFetchRequest(fetchRequest)
        return result as? [NSManagedObject] ?? []
    }
}

extension NSPredicate {
    class func predicateWithDictionary(dict: [String: String]) -> NSPredicate {
        var predicates = [NSPredicate]()
        for (key, value) in dict {
            predicates.append(NSPredicate(format: "%K == %@", key, value))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}