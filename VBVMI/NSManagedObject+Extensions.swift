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
    
    class func entityDescriptionInContext(_ context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: VB_entityName(), in: context)
    }
    
    class func findFirstOrCreate<T: NSManagedObject>(_ predicate: NSPredicate, context: NSManagedObjectContext) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: VB_entityName())
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescriptionInContext(context)
        
        var results = [AnyObject]()
        context.performAndWait({ () -> Void in
            do {
                results = try context.fetch(fetchRequest)
            } catch let error {
                logger.error("Error executing fetch: \(error)")
            }
        })
        
        if let result = results.first {
            return result as? T
        }
        
        guard let entityDesciption = entityDescriptionInContext(context) else { return nil }
        var object: NSManagedObject?
        context.performAndWait { () -> Void in
            object = self.init(entity: entityDesciption, insertInto: context)
        }
        return object as? T
    }
    
    class func findFirstOrCreateWithDictionary(_ dict: [String: String], context: NSManagedObjectContext) -> NSManagedObject? {
        return findFirstOrCreate(NSPredicate.predicateWithDictionary(dict), context: context)
    }
    
    class func findFirstWithDictionary(_ dict: [String: String], context: NSManagedObjectContext) -> NSManagedObject? {
        let predicate = NSPredicate.predicateWithDictionary(dict)
        return findFirstWithPredicate(predicate, context: context)
    }
    
    class func findFirst<T: NSManagedObject>(_ context: NSManagedObjectContext) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: VB_entityName())
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.fetch(fetchRequest)
        return result?.first
    }
    
    class func findFirstWithPredicate<T: NSManagedObject>(_ predicate: NSPredicate, context: NSManagedObjectContext) -> T? {
        
        let fetchRequest = NSFetchRequest<T>(entityName: VB_entityName())
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.fetch(fetchRequest)
        return result?.first
    }
    
    class func withIdentifier<T: NSManagedObject>(_ identifier: NSManagedObjectID, context: NSManagedObjectContext) throws -> T? {
        return try context.existingObject(with: identifier) as? T
    }
    
    class func findAllWithDictionary(_ dict: [String: String], context: NSManagedObjectContext) -> [NSManagedObject] {
        let predicate = NSPredicate.predicateWithDictionary(dict)
        
        return findAllWithPredicate(predicate, context: context)
    }
    
    class func findAllWithPredicate<T: NSManagedObject>(_ predicate: NSPredicate, context: NSManagedObjectContext) -> [T] {
        
        let fetchRequest = NSFetchRequest<T>(entityName: VB_entityName())
        fetchRequest.predicate = predicate
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.fetch(fetchRequest)
        return result ?? []
    }
    
    class func findAll<T: NSManagedObject>(_ context: NSManagedObjectContext) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: VB_entityName())
        fetchRequest.entity = entityDescriptionInContext(context)
        
        let result = try? context.fetch(fetchRequest)
        return result ?? []
    }
}

extension NSPredicate {
    class func predicateWithDictionary(_ dict: [String: String]) -> NSPredicate {
        var predicates = [NSPredicate]()
        for (key, value) in dict {
            predicates.append(NSPredicate(format: "%K == %@", key, value))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
