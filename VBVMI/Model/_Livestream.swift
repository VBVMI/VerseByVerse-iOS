// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Livestream.swift instead.

import Foundation
import CoreData

public enum LivestreamAttributes: String {
    case expirationDate = "expirationDate"
    case identifier = "identifier"
    case postedDate = "postedDate"
    case title = "title"
    case videoId = "videoId"
}

open class _Livestream: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Livestream"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Livestream.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var expirationDate: Date?

    @NSManaged open
    var identifier: String

    @NSManaged open
    var postedDate: Date?

    @NSManaged open
    var title: String?

    @NSManaged open
    var videoId: String?

    // MARK: - Relationships

    // MARK: - Fetched Properties

}

