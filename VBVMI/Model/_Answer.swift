// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Answer.swift instead.

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
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Answer.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
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
    var completed: NSNumber?

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var identifier: String?

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
    var topics: NSSet

}

extension _Answer {

    func addTopics(objects: NSSet) {
        let mutable = self.topics.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.topics = mutable.copy() as! NSSet
    }

    func removeTopics(objects: NSSet) {
        let mutable = self.topics.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.topics = mutable.copy() as! NSSet
    }

    func addTopicsObject(value: Topic) {
        let mutable = self.topics.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.topics = mutable.copy() as! NSSet
    }

    func removeTopicsObject(value: Topic) {
        let mutable = self.topics.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.topics = mutable.copy() as! NSSet
    }

}

