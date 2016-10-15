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

open class _Topic: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Topic"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Topic.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var identifier: String?

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    @NSManaged open
    var answers: Set<Answer>

    @NSManaged open
    var articles: Set<Article>

    @NSManaged open
    var lessons: Set<Lesson>

    @NSManaged open
    var studies: Set<Study>

    // MARK: - Fetched Properties

}

extension _Topic {

    func addAnswers(_ objects: Set<Answer>) {
        self.answers = self.answers.union(objects)
    }

    func removeAnswers(_ objects: Set<Answer>) {
        self.answers = self.answers.subtracting(objects)
    }

    func addAnswersObject(_ value: Answer) {
        self.answers = self.answers.union([value])
    }

    func removeAnswersObject(_ value: Answer) {
        self.answers = self.answers.subtracting([value])
    }

}

extension _Topic {

    func addArticles(_ objects: Set<Article>) {
        self.articles = self.articles.union(objects)
    }

    func removeArticles(_ objects: Set<Article>) {
        self.articles = self.articles.subtracting(objects)
    }

    func addArticlesObject(_ value: Article) {
        self.articles = self.articles.union([value])
    }

    func removeArticlesObject(_ value: Article) {
        self.articles = self.articles.subtracting([value])
    }

}

extension _Topic {

    func addLessons(_ objects: Set<Lesson>) {
        self.lessons = self.lessons.union(objects)
    }

    func removeLessons(_ objects: Set<Lesson>) {
        self.lessons = self.lessons.subtracting(objects)
    }

    func addLessonsObject(_ value: Lesson) {
        self.lessons = self.lessons.union([value])
    }

    func removeLessonsObject(_ value: Lesson) {
        self.lessons = self.lessons.subtracting([value])
    }

}

extension _Topic {

    func addStudies(_ objects: Set<Study>) {
        self.studies = self.studies.union(objects)
    }

    func removeStudies(_ objects: Set<Study>) {
        self.studies = self.studies.subtracting(objects)
    }

    func addStudiesObject(_ value: Study) {
        self.studies = self.studies.union([value])
    }

    func removeStudiesObject(_ value: Study) {
        self.studies = self.studies.subtracting([value])
    }

}

