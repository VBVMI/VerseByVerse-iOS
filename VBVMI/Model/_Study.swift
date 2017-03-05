// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Study.swift instead.

import Foundation
import CoreData

public enum StudyAttributes: String {
    case averageRating = "averageRating"
    case bibleIndex = "bibleIndex"
    case completed = "completed"
    case descriptionText = "descriptionText"
    case identifier = "identifier"
    case imageSource = "imageSource"
    case lessonCount = "lessonCount"
    case lessonsCompleted = "lessonsCompleted"
    case podcastLink = "podcastLink"
    case studyIndex = "studyIndex"
    case studyType = "studyType"
    case thumbnailAltText = "thumbnailAltText"
    case thumbnailSource = "thumbnailSource"
    case title = "title"
    case url = "url"
}

public enum StudyRelationships: String {
    case topics = "topics"
}

open class _Study: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Study"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Study.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var averageRating: String?

    @NSManaged open
    var bibleIndex: Int32

    @NSManaged open
    var completed: Bool

    @NSManaged open
    var descriptionText: String

    @NSManaged open
    var identifier: String

    @NSManaged open
    var imageSource: String?

    @NSManaged open
    var lessonCount: Int32

    @NSManaged open
    var lessonsCompleted: Int32

    @NSManaged open
    var podcastLink: String?

    @NSManaged open
    var studyIndex: Int32

    @NSManaged open
    var studyType: String

    @NSManaged open
    var thumbnailAltText: String?

    @NSManaged open
    var thumbnailSource: String?

    @NSManaged open
    var title: String

    @NSManaged open
    var url: String?

    // MARK: - Relationships

    @NSManaged open
    var topics: Set<Topic>

    // MARK: - Fetched Properties

}

extension _Study {

    func add(topics objects: Set<Topic>) {
        self.topics = self.topics.union(objects)
    }

    func remove(topics objects: Set<Topic>) {
        self.topics = self.topics.subtracting(objects)
    }

    func add(topicsObject value: Topic) {
        self.topics = self.topics.union([value])
    }

    func remove(topicsObject value: Topic) {
        self.topics = self.topics.subtracting([value])
    }

}

