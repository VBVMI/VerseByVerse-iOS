// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.swift instead.

import CoreData

public enum ChannelAttributes: String {
    case averageRating = "averageRating"
    case channelIndex = "channelIndex"
    case descriptionText = "descriptionText"
    case identifier = "identifier"
    case postedDate = "postedDate"
    case thumbnailAltText = "thumbnailAltText"
    case thumbnailSource = "thumbnailSource"
    case title = "title"
}

public enum ChannelRelationships: String {
    case videos = "videos"
}

public class _Channel: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Channel"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Channel.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var averageRating: String?

    @NSManaged public
    var channelIndex: Int32

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var identifier: String?

    @NSManaged public
    var postedDate: NSDate?

    @NSManaged public
    var thumbnailAltText: String?

    @NSManaged public
    var thumbnailSource: String?

    @NSManaged public
    var title: String?

    // MARK: - Relationships

    @NSManaged public
    var videos: NSSet

}

extension _Channel {

    func addVideos(objects: NSSet) {
        let mutable = self.videos.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.videos = mutable.copy() as! NSSet
    }

    func removeVideos(objects: NSSet) {
        let mutable = self.videos.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.videos = mutable.copy() as! NSSet
    }

    func addVideosObject(value: Video) {
        let mutable = self.videos.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.videos = mutable.copy() as! NSSet
    }

    func removeVideosObject(value: Video) {
        let mutable = self.videos.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.videos = mutable.copy() as! NSSet
    }

}

