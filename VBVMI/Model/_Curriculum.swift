// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Curriculum.swift instead.

import Foundation
import CoreData

public enum CurriculumAttributes: String {
    case coverImage = "coverImage"
    case identifier = "identifier"
    case postedDate = "postedDate"
    case title = "title"
    case url = "url"
}

open class _Curriculum: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Curriculum"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Curriculum.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var coverImage: String

    @NSManaged open
    var identifier: String

    @NSManaged open
    var postedDate: Date

    @NSManaged open
    var title: String

    @NSManaged open
    var url: String

    // MARK: - Relationships

    // MARK: - Fetched Properties

}

