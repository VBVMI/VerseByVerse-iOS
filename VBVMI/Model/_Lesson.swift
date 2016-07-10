// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Lesson.swift instead.

import CoreData

public enum LessonAttributes: String {
    case audioLength = "audioLength"
    case audioProgress = "audioProgress"
    case audioSourceURL = "audioSourceURL"
    case averageRating = "averageRating"
    case completed = "completed"
    case dateStudyGiven = "dateStudyGiven"
    case descriptionText = "descriptionText"
    case identifier = "identifier"
    case lessonIndex = "lessonIndex"
    case lessonNumber = "lessonNumber"
    case lessonTitle = "lessonTitle"
    case location = "location"
    case postedDate = "postedDate"
    case studentAidURL = "studentAidURL"
    case studyIdentifier = "studyIdentifier"
    case teacherAid = "teacherAid"
    case title = "title"
    case transcriptURL = "transcriptURL"
    case videoLength = "videoLength"
    case videoSourceURL = "videoSourceURL"
}

public enum LessonRelationships: String {
    case topics = "topics"
}

public class _Lesson: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Lesson"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Lesson.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var audioLength: String?

    @NSManaged public
    var audioProgress: Double

    @NSManaged public
    var audioSourceURL: String?

    @NSManaged public
    var averageRating: String?

    @NSManaged public
    var completed: NSNumber?

    @NSManaged public
    var dateStudyGiven: NSDate?

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var identifier: String

    @NSManaged public
    var lessonIndex: Int32

    @NSManaged public
    var lessonNumber: String?

    @NSManaged public
    var lessonTitle: String?

    @NSManaged public
    var location: String?

    @NSManaged public
    var postedDate: NSDate?

    @NSManaged public
    var studentAidURL: String?

    @NSManaged public
    var studyIdentifier: String

    @NSManaged public
    var teacherAid: String?

    @NSManaged public
    var title: String

    @NSManaged public
    var transcriptURL: String?

    @NSManaged public
    var videoLength: String?

    @NSManaged public
    var videoSourceURL: String?

    // MARK: - Relationships

    @NSManaged public
    var topics: NSSet

}

extension _Lesson {

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

