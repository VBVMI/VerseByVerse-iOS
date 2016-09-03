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
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _AudioPlayer.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var currentTime: NSNumber?

    @NSManaged public
    var lessonIdentifier: String?

    @NSManaged public
    var studyIdentifier: String?

    // MARK: - Relationships

    @NSManaged public
    var lesson: [Lesson]

    @NSManaged public
    var study: [Study]

}

