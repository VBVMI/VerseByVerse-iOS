// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.swift instead.

import Foundation
import CoreData

public enum EventAttributes: String {
    case descriptionText = "descriptionText"
    case eventDateComponents = "eventDateComponents"
    case eventIndex = "eventIndex"
    case identifier = "identifier"
    case location = "location"
    case map = "map"
    case thumbnailAltText = "thumbnailAltText"
    case thumbnailSource = "thumbnailSource"
    case title = "title"
    case type = "type"
}

public class _Event: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Event"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Event.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var eventDateComponents: NSDateComponents?

    @NSManaged public
    var eventIndex: Int32

    @NSManaged public
    var identifier: String

    @NSManaged public
    var location: String?

    @NSManaged public
    var map: String?

    @NSManaged public
    var thumbnailAltText: String?

    @NSManaged public
    var thumbnailSource: String?

    @NSManaged public
    var title: String?

    @NSManaged public
    var type: String?

    // MARK: - Relationships

}

