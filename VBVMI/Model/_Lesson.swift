// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Lesson.swift instead.

import Foundation
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
    case isPlaceholder = "isPlaceholder"
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
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Lesson.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
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
    var completed: Bool

    @NSManaged public
    var dateStudyGiven: NSDate?

    @NSManaged public
    var descriptionText: String?

    @NSManaged public
    var identifier: String

    @NSManaged public
    var isPlaceholder: Bool

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
    var topics: Set<Topic>

    // MARK: - Fetched Properties

}

extension _Lesson {

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

