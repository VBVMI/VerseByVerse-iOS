// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.swift instead.

import Foundation
import CoreData

public enum VideoAttributes: String {
    case descriptionText = "descriptionText"
    case identifier = "identifier"
    case recordedDate = "recordedDate"
    case service = "service"
    case serviceVideoIdentifier = "serviceVideoIdentifier"
    case thumbnailSource = "thumbnailSource"
    case title = "title"
    case url = "url"
    case videoIndex = "videoIndex"
    case videoLength = "videoLength"
    case videoSource = "videoSource"
}

public enum VideoRelationships: String {
    case channel = "channel"
    case curriculum = "curriculum"
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
    var descriptionText: String?

    @NSManaged open
    var identifier: String

    @NSManaged open
    var recordedDate: Date?

    @NSManaged open
    var service: String?

    @NSManaged open
    var serviceVideoIdentifier: String?

    @NSManaged open
    var thumbnailSource: String?

    @NSManaged open
    var title: String?

    @NSManaged open
    var url: String?

    @NSManaged open
    var videoIndex: Int32

    @NSManaged open
    var videoLength: String?

    @NSManaged open
    var videoSource: String?

    // MARK: - Relationships

    @NSManaged open
    var channel: Channel?

    @NSManaged open
    var curriculum: Curriculum?

    // MARK: - Fetched Properties

}

