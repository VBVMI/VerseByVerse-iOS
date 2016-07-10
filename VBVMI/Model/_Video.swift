// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.swift instead.

import CoreData

public enum VideoAttributes: String {
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

public enum VideoRelationships: String {
    case channel = "channel"
}

public class _Video: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Video"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Video.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var averageRating: String?

    @NSManaged public
    var category: String?

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var identifier: String?

    @NSManaged public
    var postedDate: NSDate?

    @NSManaged public
    var recordedDate: NSDate?

    @NSManaged public
    var thumbnailAltText: String?

    @NSManaged public
    var thumbnailSource: String?

    @NSManaged public
    var title: String?

    @NSManaged public
    var videoIndex: Int32

    @NSManaged public
    var videoLength: String?

    @NSManaged public
    var videoSource: String?

    // MARK: - Relationships

    @NSManaged public
    var channel: Channel?

}

