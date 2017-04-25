// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.swift instead.

import Foundation
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
    case url = "url"
}

public enum ChannelRelationships: String {
    case videos = "videos"
}

open class _Channel: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Channel"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Channel.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var averageRating: String?

    @NSManaged open
    var channelIndex: Int32

    @NSManaged open
    var descriptionText: String?

    @NSManaged open
    var identifier: String

    @NSManaged open
    var postedDate: Date?

    @NSManaged open
    var thumbnailAltText: String?

    @NSManaged open
    var thumbnailSource: String?

    @NSManaged open
    var title: String?

    @NSManaged open
    var url: String?

    // MARK: - Relationships

    @NSManaged open
    var videos: Set<Video>

    // MARK: - Fetched Properties

}

extension _Channel {

    func add(videos objects: Set<Video>) {
        self.videos = self.videos.union(objects)
    }

    func remove(videos objects: Set<Video>) {
        self.videos = self.videos.subtracting(objects)
    }

    func add(videosObject value: Video) {
        self.videos = self.videos.union([value])
    }

    func remove(videosObject value: Video) {
        self.videos = self.videos.subtracting([value])
    }

}

