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
}

public enum StudyRelationships: String {
    case topics = "topics"
}

public class _Study: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Study"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
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

    @NSManaged public
    var averageRating: String?

    @NSManaged public
    var bibleIndex: Int32

    @NSManaged public
    var completed: Bool

    @NSManaged public
    var descriptionText: String

    @NSManaged public
    var identifier: String

    @NSManaged public
    var imageSource: String?

    @NSManaged public
    var lessonCount: Int32

    @NSManaged public
    var lessonsCompleted: Int32

    @NSManaged public
    var podcastLink: String?

    @NSManaged public
    var studyIndex: Int32

    @NSManaged public
    var studyType: String

    @NSManaged public
    var thumbnailAltText: String?

    @NSManaged public
    var thumbnailSource: String?

    @NSManaged public
    var title: String

    // MARK: - Relationships

    @NSManaged public
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

