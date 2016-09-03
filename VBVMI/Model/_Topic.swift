// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Topic.swift instead.

import Foundation
import CoreData

public enum TopicAttributes: String {
    case identifier = "identifier"
    case name = "name"
}

public enum TopicRelationships: String {
    case answers = "answers"
    case articles = "articles"
    case lessons = "lessons"
    case studies = "studies"
}

public class _Topic: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Topic"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Topic.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var identifier: String?

    @NSManaged public
    var name: String?

    // MARK: - Relationships

    @NSManaged public
    var answers: NSSet

    @NSManaged public
    var articles: NSSet

    @NSManaged public
    var lessons: NSSet

    @NSManaged public
    var studies: NSSet

}

extension _Topic {

    func addAnswers(objects: NSSet) {
        let mutable = self.answers.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.answers = mutable.copy() as! NSSet
    }

    func removeAnswers(objects: NSSet) {
        let mutable = self.answers.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.answers = mutable.copy() as! NSSet
    }

    func addAnswersObject(value: Answer) {
        let mutable = self.answers.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.answers = mutable.copy() as! NSSet
    }

    func removeAnswersObject(value: Answer) {
        let mutable = self.answers.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.answers = mutable.copy() as! NSSet
    }

}

extension _Topic {

    func addArticles(objects: NSSet) {
        let mutable = self.articles.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.articles = mutable.copy() as! NSSet
    }

    func removeArticles(objects: NSSet) {
        let mutable = self.articles.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.articles = mutable.copy() as! NSSet
    }

    func addArticlesObject(value: Article) {
        let mutable = self.articles.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.articles = mutable.copy() as! NSSet
    }

    func removeArticlesObject(value: Article) {
        let mutable = self.articles.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.articles = mutable.copy() as! NSSet
    }

}

extension _Topic {

    func addLessons(objects: NSSet) {
        let mutable = self.lessons.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.lessons = mutable.copy() as! NSSet
    }

    func removeLessons(objects: NSSet) {
        let mutable = self.lessons.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.lessons = mutable.copy() as! NSSet
    }

    func addLessonsObject(value: Lesson) {
        let mutable = self.lessons.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.lessons = mutable.copy() as! NSSet
    }

    func removeLessonsObject(value: Lesson) {
        let mutable = self.lessons.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.lessons = mutable.copy() as! NSSet
    }

}

extension _Topic {

    func addStudies(objects: NSSet) {
        let mutable = self.studies.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.studies = mutable.copy() as! NSSet
    }

    func removeStudies(objects: NSSet) {
        let mutable = self.studies.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.studies = mutable.copy() as! NSSet
    }

    func addStudiesObject(value: Study) {
        let mutable = self.studies.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.studies = mutable.copy() as! NSSet
    }

    func removeStudiesObject(value: Study) {
        let mutable = self.studies.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.studies = mutable.copy() as! NSSet
    }

}

