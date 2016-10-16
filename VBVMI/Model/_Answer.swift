// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Answer.swift instead.

import Foundation
import CoreData

public enum AnswerAttributes: String {
    case authorName = "authorName"
    case authorThumbnailAltText = "authorThumbnailAltText"
    case authorThumbnailSource = "authorThumbnailSource"
    case averageRating = "averageRating"
    case body = "body"
    case category = "category"
    case completed = "completed"
    case descriptionText = "descriptionText"
    case identifier = "identifier"
    case postedDate = "postedDate"
    case qaThumbnailAltText = "qaThumbnailAltText"
    case qaThumbnailSource = "qaThumbnailSource"
    case title = "title"
}

public enum AnswerRelationships: String {
    case topics = "topics"
}

open class _Answer: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Answer"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Answer.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var authorName: String?

    @NSManaged open
    var authorThumbnailAltText: String?

    @NSManaged open
    var authorThumbnailSource: String?

    @NSManaged open
    var averageRating: String?

    @NSManaged open
    var body: String?

    @NSManaged open
    var category: String?

    @NSManaged open
    var completed: Bool

    @NSManaged open
    var descriptionText: String?

    @NSManaged open
    var identifier: String

    @NSManaged open
    var postedDate: Date?

    @NSManaged open
    var qaThumbnailAltText: String?

    @NSManaged open
    var qaThumbnailSource: String?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var topics: Set<Topic>

    // MARK: - Fetched Properties

}

extension _Answer {

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

