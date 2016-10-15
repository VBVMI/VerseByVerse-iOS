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

