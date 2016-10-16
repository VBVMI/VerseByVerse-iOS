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

open class _Event: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Event"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Event.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var descriptionText: String?

    @NSManaged open
    var eventDateComponents: DateComponents?

    @NSManaged open
    var eventIndex: Int32

    @NSManaged open
    var identifier: String

    @NSManaged open
    var location: String?

    @NSManaged open
    var map: String?

    @NSManaged open
    var thumbnailAltText: String?

    @NSManaged open
    var thumbnailSource: String?

    @NSManaged open
    var title: String?

    @NSManaged open
    var type: String?

    // MARK: - Relationships

    // MARK: - Fetched Properties

}

