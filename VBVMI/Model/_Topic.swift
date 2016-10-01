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
    var answers: Set<Answer>

    @NSManaged public
    var articles: Set<Article>

    @NSManaged public
    var lessons: Set<Lesson>

    @NSManaged public
    var studies: Set<Study>

    // MARK: - Fetched Properties

}

extension _Topic {

    func addAnswers(objects: Set<Answer>) {
        self.answers = self.answers.union(objects)
    }

    func removeAnswers(objects: Set<Answer>) {
        self.answers = self.answers.subtract(objects)
    }

    func addAnswersObject(value: Answer) {
        self.answers = self.answers.union([value])
    }

    func removeAnswersObject(value: Answer) {
        self.answers = self.answers.subtract([value])
    }

}

extension _Topic {

    func addArticles(objects: Set<Article>) {
        self.articles = self.articles.union(objects)
    }

    func removeArticles(objects: Set<Article>) {
        self.articles = self.articles.subtract(objects)
    }

    func addArticlesObject(value: Article) {
        self.articles = self.articles.union([value])
    }

    func removeArticlesObject(value: Article) {
        self.articles = self.articles.subtract([value])
    }

}

extension _Topic {

    func addLessons(objects: Set<Lesson>) {
        self.lessons = self.lessons.union(objects)
    }

    func removeLessons(objects: Set<Lesson>) {
        self.lessons = self.lessons.subtract(objects)
    }

    func addLessonsObject(value: Lesson) {
        self.lessons = self.lessons.union([value])
    }

    func removeLessonsObject(value: Lesson) {
        self.lessons = self.lessons.subtract([value])
    }

}

extension _Topic {

    func addStudies(objects: Set<Study>) {
        self.studies = self.studies.union(objects)
    }

    func removeStudies(objects: Set<Study>) {
        self.studies = self.studies.subtract(objects)
    }

    func addStudiesObject(value: Study) {
        self.studies = self.studies.union([value])
    }

    func removeStudiesObject(value: Study) {
        self.studies = self.studies.subtract([value])
    }

}

