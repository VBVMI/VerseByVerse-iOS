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
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Study.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var averageRating: String?

    @NSManaged public
    var bibleIndex: Int32

    @NSManaged public
    var completed: NSNumber?

    @NSManaged public
    var descriptionText: String

    @NSManaged public
    var identifier: String

    @NSManaged public
    var imageSource: String?

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
    var topics: NSSet

}

extension _Study {

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

