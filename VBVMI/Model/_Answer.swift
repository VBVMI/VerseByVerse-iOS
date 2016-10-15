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

public class _Answer: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Answer"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
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

    @NSManaged public
    var authorName: String?

    @NSManaged public
    var authorThumbnailAltText: String?

    @NSManaged public
    var authorThumbnailSource: String?

    @NSManaged public
    var averageRating: String?

    @NSManaged public
    var body: String?

    @NSManaged public
    var category: String?

    @NSManaged public
    var completed: Bool

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var identifier: String

    @NSManaged public
    var postedDate: NSDate?

    @NSManaged public
    var qaThumbnailAltText: String?

    @NSManaged public
    var qaThumbnailSource: String?

    @NSManaged public
    var title: String?

    // MARK: - Relationships

    @NSManaged public
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

