// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Article.swift instead.

import Foundation
import CoreData

public enum ArticleAttributes: String {
    case articleThumbnailAltText = "articleThumbnailAltText"
    case articleThumbnailSource = "articleThumbnailSource"
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
    case title = "title"
}

public enum ArticleRelationships: String {
    case topics = "topics"
}

open class _Article: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Article"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Article.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var articleThumbnailAltText: String?

    @NSManaged open
    var articleThumbnailSource: String?

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
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var topics: Set<Topic>

    // MARK: - Fetched Properties

}

extension _Article {

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

