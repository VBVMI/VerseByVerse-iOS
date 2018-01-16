// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StudyCategory.swift instead.

import Foundation
import CoreData

public enum StudyCategoryAttributes: String {
    case identifier = "identifier"
    case name = "name"
}

open class _StudyCategory: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "StudyCategory"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _StudyCategory.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var identifier: String?

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    // MARK: - Fetched Properties

}

