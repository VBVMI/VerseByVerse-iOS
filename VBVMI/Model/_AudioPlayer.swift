// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AudioPlayer.swift instead.

import Foundation
import CoreData

open enum AudioPlayerAttributes: String {
    case currentTime = "currentTime"
    case lessonIdentifier = "lessonIdentifier"
    case studyIdentifier = "studyIdentifier"
}

open enum AudioPlayerFetchedProperties: String {
    case lesson = "lesson"
    case study = "study"
}

open class _AudioPlayer: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "AudioPlayer"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _AudioPlayer.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var currentTime: Double

    @NSManaged open
    var lessonIdentifier: String?

    @NSManaged open
    var studyIdentifier: String?

    // MARK: - Relationships

    // MARK: - Fetched Properties

    @NSManaged open
    var lesson: [Lesson]

    @NSManaged open
    var study: [Study]

}

