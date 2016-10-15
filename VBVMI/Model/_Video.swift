// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.swift instead.

import Foundation
import CoreData

open enum VideoAttributes: String {
    case averageRating = "averageRating"
    case category = "category"
    case descriptionText = "descriptionText"
    case identifier = "identifier"
    case postedDate = "postedDate"
    case recordedDate = "recordedDate"
    case thumbnailAltText = "thumbnailAltText"
    case thumbnailSource = "thumbnailSource"
    case title = "title"
    case videoIndex = "videoIndex"
    case videoLength = "videoLength"
    case videoSource = "videoSource"
}

open enum VideoRelationships: String {
    case channel = "channel"
}

open class _Video: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Video"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Video.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var averageRating: String?

    @NSManaged open
    var category: String?

    @NSManaged open
    var descriptionText: String?

    @NSManaged open
    var identifier: String?

    @NSManaged open
    var postedDate: Date?

    @NSManaged open
    var recordedDate: Date?

    @NSManaged open
    var thumbnailAltText: String?

    @NSManaged open
    var thumbnailSource: String?

    @NSManaged open
    var title: String?

    @NSManaged open
    var videoIndex: Int32

    @NSManaged open
    var videoLength: String?

    @NSManaged open
    var videoSource: String?

    // MARK: - Relationships

    @NSManaged open
    var channel: Channel?

    // MARK: - Fetched Properties

}

