// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AudioPlayer.swift instead.

import Foundation
import CoreData

public enum AudioPlayerAttributes: String {
    case currentTime = "currentTime"
    case lessonIdentifier = "lessonIdentifier"
    case studyIdentifier = "studyIdentifier"
}

public enum AudioPlayerFetchedProperties: String {
    case lesson = "lesson"
    case study = "study"
}

public class _AudioPlayer: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "AudioPlayer"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
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

    @NSManaged public
    var currentTime: Double

    @NSManaged public
    var lessonIdentifier: String?

    @NSManaged public
    var studyIdentifier: String?

    // MARK: - Relationships

    // MARK: - Fetched Properties

    @NSManaged public
    var lesson: [Lesson]

    @NSManaged public
    var study: [Study]

}

