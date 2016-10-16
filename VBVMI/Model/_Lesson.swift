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

open class _Lesson: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Lesson"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
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

    @NSManaged open
    var audioLength: String?

    @NSManaged open
    var audioProgress: Double

    @NSManaged open
    var audioSourceURL: String?

    @NSManaged open
    var averageRating: String?

    @NSManaged open
    var completed: Bool

    @NSManaged open
    var dateStudyGiven: Date?

    @NSManaged open
    var descriptionText: String?

    @NSManaged open
    var identifier: String

    @NSManaged open
    var isPlaceholder: Bool

    @NSManaged open
    var lessonIndex: Int32

    @NSManaged open
    var lessonNumber: String?

    @NSManaged open
    var lessonTitle: String?

    @NSManaged open
    var location: String?

    @NSManaged open
    var postedDate: Date?

    @NSManaged open
    var studentAidURL: String?

    @NSManaged open
    var studyIdentifier: String

    @NSManaged open
    var teacherAid: String?

    @NSManaged open
    var title: String

    @NSManaged open
    var transcriptURL: String?

    @NSManaged open
    var videoLength: String?

    @NSManaged open
    var videoSourceURL: String?

    // MARK: - Relationships

    @NSManaged open
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

