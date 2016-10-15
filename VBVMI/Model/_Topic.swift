// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Topic.swift instead.

import Foundation
import CoreData

open enum TopicAttributes: String {
    case identifier = "identifier"
    case name = "name"
}

open enum TopicRelationships: String {
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

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Topic.entity(managedObjectContext: managedObjectContext) else { return nil }
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

    func add(answers objects: Set<Answer>) {
        self.answers = self.answers.union(objects)
    }

    func remove(answers objects: Set<Answer>) {
        self.answers = self.answers.subtracting(objects)
    }

    func add(answersObject value: Answer) {
        self.answers = self.answers.union([value])
    }

    func remove(answersObject value: Answer) {
        self.answers = self.answers.subtracting([value])
    }

}

extension _Topic {

    func add(articles objects: Set<Article>) {
        self.articles = self.articles.union(objects)
    }

    func remove(articles objects: Set<Article>) {
        self.articles = self.articles.subtracting(objects)
    }

    func add(articlesObject value: Article) {
        self.articles = self.articles.union([value])
    }

    func remove(articlesObject value: Article) {
        self.articles = self.articles.subtracting([value])
    }

}

extension _Topic {

    func add(lessons objects: Set<Lesson>) {
        self.lessons = self.lessons.union(objects)
    }

    func remove(lessons objects: Set<Lesson>) {
        self.lessons = self.lessons.subtracting(objects)
    }

    func add(lessonsObject value: Lesson) {
        self.lessons = self.lessons.union([value])
    }

    func remove(lessonsObject value: Lesson) {
        self.lessons = self.lessons.subtracting([value])
    }

}

extension _Topic {

    func add(studies objects: Set<Study>) {
        self.studies = self.studies.union(objects)
    }

    func remove(studies objects: Set<Study>) {
        self.studies = self.studies.subtracting(objects)
    }

    func add(studiesObject value: Study) {
        self.studies = self.studies.union([value])
    }

    func remove(studiesObject value: Study) {
        self.studies = self.studies.subtracting([value])
    }

}

