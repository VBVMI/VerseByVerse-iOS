//
//  APIDataManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 1/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation

import CoreData
import Alamofire
//import SwiftString

enum APIDataManagerError : Error {
    case missingID
    case modelCreationFailed
}

func nullOrString(_ str: String?) -> String? {
    guard let string = str else {
        return nil
    }
    if string.count > 0 {
        return string
    }
    return nil
}

protocol AssetsDownloadable {
    func directory() -> URL?
}

typealias Conversion<T> = (NSManagedObjectContext, T) throws ->()

class APIDataManager {

    static func categories(completion: @escaping (Error?)->()) {
        
        
        downloadToJSONArray(.categories, conversionBlock: { (context, results) in
            let existingCategories: [StudyCategory] = StudyCategory.findAll(context)
            var existingCategoryIds = Set<String>(existingCategories.map({ $0.identifier }))
            
            try results.enumerated().forEach({ (index, result) in
                let category = try StudyCategory.importStudyCategory(result, context: context)
                existingCategoryIds.remove(category.identifier)
            })
            
            if existingCategoryIds.count > 0 {
                let categoriesToDelete: [StudyCategory] = StudyCategory.findAllWithPredicate(NSPredicate(format: "%K in %@", StudyCategoryAttributes.identifier.rawValue, existingCategoryIds), context: context)
                categoriesToDelete.forEach({ context.delete($0)})
            }
        } as Conversion<[APIStudyCategory]>, completion: completion)
    }
    
    static func core() {
        downloadToJSONArray(.core, conversionBlock: { (context, core) in
            let existingStudies: [Study] = Study.findAll(context)
            
            var existingStudyIds = Set<String>(existingStudies.map( { $0.identifier } ))
            
            try core.studies.enumerated().forEach({ (index, studyDict) in
                let study = try Study.importStudy(studyDict, context: context, index: index)
                let _ = existingStudyIds.remove(study.identifier)
            })
            
            if existingStudyIds.count > 0 {
                let studiesToDelete: [Study] = Study.findAllWithPredicate(NSPredicate(format: "%K in %@", StudyAttributes.identifier.rawValue, existingStudyIds), context: context)
                let lessonsToDelete: [Lesson] = Lesson.findAllWithPredicate(NSPredicate(format: "%K in %@", LessonAttributes.studyIdentifier.rawValue, existingStudyIds), context: context)
                studiesToDelete.forEach({ (study) in
                    context.delete(study)
                })
                lessonsToDelete.forEach({ (lesson) in
                    context.delete(lesson)
                })
            }
        } as Conversion<APICore>)
    }
    
    static func lessons(_ studyID: String) {
        downloadToJSONArray(JsonAPI.lesson(identifier: studyID), conversionBlock: { (context, result) in
            //We should fetch old lessons for merging and possible deletion
            let existingLessons = Lesson.findAllWithDictionary([LessonAttributes.studyIdentifier.rawValue: studyID], context: context) as? [Lesson] ?? []
            var existingLessonIds = existingLessons.map({ (lesson) -> String in
                return lesson.identifier
            })
            
            try result.lessons.forEach({ (lessonDict) in
                let lesson = try Lesson.importLesson(lessonDict, studyID: studyID, context: context)
                if let index = existingLessonIds.firstIndex(of: lesson.identifier) {
                    existingLessonIds.remove(at: index)
                }
            })
            
            if existingLessonIds.count > 0 {
                let lessonsToDelete: [Lesson] = Lesson.findAllWithPredicate(NSPredicate(format: "%K in %@", LessonAttributes.identifier.rawValue, existingLessonIds), context: context)
                if lessonsToDelete.count > 0 {
                    for lesson in lessonsToDelete {
                        context.delete(lesson)
                    }
                }
            }
        } as Conversion<APILessons>)
    }
    
    static func latestLessons() {
        downloadToJSONArray(JsonAPI.latestLessons, conversionBlock: { (context, result) in
            try result.lessons.forEach({ (lessonDict) in
                if let studyIdentifier = lessonDict.studyIdentifier {
                    try Lesson.importLesson(lessonDict, studyID: studyIdentifier, context: context)
                }
            })
            } as Conversion<APILessons>)
    }
    
    static func latestArticles() {
        downloadToJSONArray(JsonAPI.articlesP, conversionBlock: { (context, result) in
            var count = 0
            for JSONModel in result.articles {
                let article = try Article.importArticle(JSONModel, context: context)
                if article.objectID.isTemporaryID {
                    //Then the object isn't persisted yet
                    count += 1
                }
            }
            if count == result.articles.count {
                //Then All of the objects are new... lets DOWNLOAD ALL THE ARTICLES
                DispatchQueue.main.async { () -> Void in
                    allTheArticles()
                }
            }
        } as Conversion<APIArticles>)
        // download the articles P
    }
    
    static func allTheArticles(_ completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.articles, conversionBlock: { (context, result) in
            let existingArticles: [Article] = Article.findAll(context)
            
            var existingArticleIds = Set<String>(existingArticles.map( { $0.identifier } ))
            
            for JSONModel in result.articles {
                let article = try Article.importArticle(JSONModel, context: context)
                let _ = existingArticleIds.remove(article.identifier)
            }
            
            if existingArticleIds.count > 0 {
                let articlesToDelete: [Article] = Article.findAllWithPredicate(NSPredicate(format: "%K in %@", ArticleAttributes.identifier.rawValue, existingArticleIds), context: context)
                
                articlesToDelete.forEach({ (article) in
                    context.delete(article)
                })
            }
            } as Conversion<APIArticles>) { (error) in
                if let completion = completion {
                    DispatchQueue.main.async { () -> Void in
                        completion()
                    }
                }
        }
    }
    
    static func latestAnswers() {
        downloadToJSONArray(JsonAPI.qAp, conversionBlock: { (context, result) in
            var count = 0
            for JSONModel in result.answers {
                let article = try Answer.importAnswer(JSONModel, context: context)
                if article.objectID.isTemporaryID {
                    //Then the object isn't persisted yet
                    count += 1
                }
            }
            if count == result.answers.count {
                //Then All of the objects are new... lets DOWNLOAD ALL THE ANSWERS
                DispatchQueue.main.async { () -> Void in
                    allTheAnswers()
                }
            }
        } as Conversion<APIAnswers>)
    }
    
    static func allTheAnswers(_ completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.qa, conversionBlock: { (context, result) in
            let existingAnswers: [Answer] = Answer.findAll(context)
            
            var existingAnswerIds = Set<String>(existingAnswers.map( { $0.identifier } ))
            
            for JSONModel in result.answers {
                let answer = try Answer.importAnswer(JSONModel, context: context)
                let _ = existingAnswerIds.remove(answer.identifier)
            }
            
            if existingAnswerIds.count > 0 {
                let answerToDelete: [Answer] = Answer.findAllWithPredicate(NSPredicate(format: "%K in %@", AnswerAttributes.identifier.rawValue, existingAnswerIds), context: context)
                
                answerToDelete.forEach({ (article) in
                    context.delete(article)
                })
            }
        } as Conversion<APIAnswers>) { _ in
            if let completion = completion {
                DispatchQueue.main.async { () -> Void in
                    completion()
                }
            }
        }
    }
    
    static func allTheChannels() {
        downloadToJSONArray(JsonAPI.channels, conversionBlock: { (context, result) in
            let existingChannels: [Channel] = Channel.findAll(context)
            var existingChannelIds = Set<String>(existingChannels.map({ $0.identifier }))
            
            try result.channels.enumerated().forEach({ (index, channelDict) in
                let channel = try Channel.importChannel(channelDict, context: context, index: index)
                existingChannelIds.remove(channel.identifier)
            })
            
            if existingChannelIds.count > 0 {
                let channelsToDelete: [Channel] = Channel.findAllWithPredicate(NSPredicate(format: "%K in %@", ChannelAttributes.identifier.rawValue, existingChannelIds), context: context)
                
                channelsToDelete.forEach({
                    context.delete($0)
                })
            }
            
            let orphanedVideos = Video.findAllWithPredicate(NSPredicate(format: "%K == NULL && %K == NULL", VideoRelationships.channel.rawValue, VideoRelationships.curriculum.rawValue), context: context)
            
            orphanedVideos.forEach({ (video) in
                context.delete(video)
            })
        } as Conversion<APIChannels>)
    }
    
    static func allTheCurriculums() {
        downloadToJSONArray(JsonAPI.curriculum, conversionBlock: { (context, result) in
            let existingChannels: [Curriculum] = Curriculum.findAll(context)
            var existingChannelIds = Set<String>(existingChannels.map({ $0.identifier }))
            
            try result.channels.enumerated().forEach({ (index, channelDict) in
                let channel = try Curriculum.importCurriculum(channelDict, context: context, index: index)
                existingChannelIds.remove(channel.identifier)
            })
            
            if existingChannelIds.count > 0 {
                let channelsToDelete: [Curriculum] = Curriculum.findAllWithPredicate(NSPredicate(format: "%K in %@", CurriculumAttributes.identifier.rawValue, existingChannelIds), context: context)
                
                channelsToDelete.forEach({
                    context.delete($0)
                })
            }
            
            let orphanedVideos = Video.findAllWithPredicate(NSPredicate(format: "%K == NULL && %K == NULL", VideoRelationships.channel.rawValue, VideoRelationships.curriculum.rawValue), context: context)
            
            orphanedVideos.forEach({ (video) in
                context.delete(video)
            })
        } as Conversion<APICurriculums>)
    }
    
    static func allTheEvents() {
        downloadToJSONArray(JsonAPI.events, conversionBlock: { (context, result) in
            let existingEvents: [Event] = Event.findAll(context)
            var existingEventIds = existingEvents.map({ (event) -> String in
                return event.identifier
            })
            
            try result.events.enumerated().forEach({ (index, eventDict) in
                let event = try Event.importEvent(eventDict, context: context, index: index)
                if let index = existingEventIds.firstIndex(of: event.identifier) {
                    existingEventIds.remove(at: index)
                }
            })
            
            if existingEventIds.count > 0 {
                let eventsToDelete: [Event] = Event.findAllWithPredicate(NSPredicate(format: "%K in %@", EventAttributes.identifier.rawValue, existingEventIds), context: context)
                if eventsToDelete.count > 0 {
                    for event in eventsToDelete {
                        context.delete(event)
                    }
                }
            }
        } as Conversion<APIEvents>)
    }
    
    
    fileprivate static func downloadToJSONArray<T: Decodable>(_ request: JsonAPI, conversionBlock: @escaping Conversion<T>, completion: ((Error?)->())? = nil) {
        Provider.sharedProvider.request(request) { (result) -> () in
            switch result {
            case .success(let response):
                DispatchQueue.global(qos: .background).async {
                    //logger.info("🍕resonse: \(response)")
                    let data = response.data
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(T.self, from: data)
                        
                        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        context.parent = ContextCoordinator.sharedInstance.backgroundManagedObjectContext!
                        context.perform({ () -> Void in
                            do {
                                try conversionBlock(context, results)
                            } catch let error {
                                logger.error("Error decoding modelJSON \(error)")
                                completion?(error)
                                return
                            }
                            
                            do {
                                if context.hasChanges {
                                    try context.save()
                                }
                                ContextCoordinator.sharedInstance.backgroundManagedObjectContext!.perform({ () -> Void in
                                    do {
                                        try ContextCoordinator.sharedInstance.backgroundManagedObjectContext!.save()
                                        completion?(nil)
                                    } catch (let error) {
                                        logger.error("Error saving background context:\(error)")
                                        completion?(error)
                                    }
                                    
                                })
                            } catch (let error) {
                                logger.error("Error Saving: \(error)")
                                completion?(error)
                            }
                        })
                    } catch (let error) {
                        logger.error("Error Decoding JSON: \(error)")
                        completion?(error)
                    }
                }
            case .failure(let error):
                logger.error("Error downloading objects : \(error)")
                completion?(error)
            }
        }
    }
    
    /**
     Download a file to disk. The file path will be returned.
     
     - parameter urlString: The URL string for the file to be downloaded
     - parameter progress: The optional progress block
     - parameter completion: The completion block
     */
    static func downloadFile(_ model: AssetsDownloadable, urlString: String, progress: @escaping Request.ProgressHandler, completion: @escaping(DefaultDownloadResponse) -> Void) -> Request {
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
            if let directory = model.directory() {
                return (directory.appendingPathComponent(response.suggestedFilename!), [.removePreviousFile, .createIntermediateDirectories])
            }
            
            return (temporaryURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return Alamofire.download(urlString, method: .get, to: destination).downloadProgress(closure: progress).response(completionHandler: completion)
    }
    
    static func fileExists(_ model: AssetsDownloadable, urlString: String) -> URL? {
        let fileManager = FileManager.default
        guard let getURL = URL(string: urlString) else { return nil }
        
        guard let url = model.directory() else { return nil }
        let fileName = getURL.lastPathComponent
        let fileURL  = url.appendingPathComponent(fileName)
        let path = fileURL.path
        
        if fileManager.fileExists(atPath: path) {
            return fileURL
        }
        
        return nil
    }
}
