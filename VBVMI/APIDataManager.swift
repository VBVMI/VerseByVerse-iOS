//
//  APIDataManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 1/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Decodable

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

class APIDataManager {

    static func categories(completion: @escaping (Error?)->()) {
        downloadToJSONArray(.categories, conversionBlock: { (context, JSONArray) in
            let existingCategories: [StudyCategory] = StudyCategory.findAll(context)
            var existingCategoryIds = Set<String>(existingCategories.map({ $0.identifier }))
            
            try JSONArray.enumerated().forEach({ (index, dict) in
                let category = try StudyCategory.decodeJSON(dict, context: context)
                existingCategoryIds.remove(category.identifier)
            })
            
            if existingCategoryIds.count > 0 {
                let categoriesToDelete: [StudyCategory] = StudyCategory.findAllWithPredicate(NSPredicate(format: "%K in %@", StudyCategoryAttributes.identifier.rawValue, existingCategoryIds), context: context)
                categoriesToDelete.forEach({ context.delete($0)})
            }
        }, completion: completion)
    }
    
    static func core() {
        downloadToJSONArray(.core, arrayNode: "studies", conversionBlock: { (context, JSONArray) -> () in
            
            let existingStudies: [Study] = Study.findAll(context)
            
            var existingStudyIds = Set<String>(existingStudies.map( { $0.identifier } ))
            
            try JSONArray.enumerated().forEach({ (index, studyDict) in
                let study = try Study.decodeJSON(studyDict, context: context, index: index)
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
        })
    }
    
    static func lessons(_ studyID: String) {
        
        downloadToJSONArray(JsonAPI.lesson(identifier: studyID), arrayNode: "lessons", conversionBlock: { (context, JSONModels) -> () in
            //We should fetch old lessons for merging and possible deletion
            let existingLessons = Lesson.findAllWithDictionary([LessonAttributes.studyIdentifier.rawValue: studyID], context: context) as? [Lesson] ?? []
            var existingLessonIds = existingLessons.map({ (lesson) -> String in
                return lesson.identifier
            })
            
            try JSONModels.forEach({ (lessonDict) in
                let lesson = try Lesson.decodeJSON(lessonDict, studyID: studyID, context: context)
                if let index = existingLessonIds.index(of: lesson.identifier) {
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
        })
    }
    
    static func latestLessons() {
        
        downloadToJSONArray(JsonAPI.latestLessons, arrayNode: "lessons", conversionBlock: { (context, JSONModels) in
            try JSONModels.forEach({ (lessonDict) in
                if let studyIdentifier = lessonDict["studyIdentifier"] as? String {
                    try Lesson.decodeJSON(lessonDict, studyID: studyIdentifier, context: context)
                }
            })
        })
        
    }
    
    static func latestArticles() {
        // download the articles P
        downloadToJSONArray(JsonAPI.articlesP, arrayNode: "articles", conversionBlock: { (context, JSONModels) -> () in
            var count = 0
            for JSONModel in JSONModels {
                let article = try Article.decodeJSON(JSONModel, context: context)
                if article.objectID.isTemporaryID {
                    //Then the object isn't persisted yet
                    count += 1
                }
            }
            if count == JSONModels.count {
                //Then All of the objects are new... lets DOWNLOAD ALL THE ARTICLES
                DispatchQueue.main.async { () -> Void in
                    allTheArticles()
                }
            }
        })
    }
    
    static func allTheArticles(_ completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.articles, arrayNode: "articles", conversionBlock: { (context, JSONArray) -> () in
            let existingArticles: [Article] = Article.findAll(context)
            
            var existingArticleIds = Set<String>(existingArticles.map( { $0.identifier } ))
            
            for JSONModel in JSONArray {
                let article = try Article.decodeJSON(JSONModel, context: context)
                let _ = existingArticleIds.remove(article.identifier)
            }
            
            if existingArticleIds.count > 0 {
                let articlesToDelete: [Article] = Article.findAllWithPredicate(NSPredicate(format: "%K in %@", ArticleAttributes.identifier.rawValue, existingArticleIds), context: context)
                
                articlesToDelete.forEach({ (article) in
                    context.delete(article)
                })
            }
        }, completion: { _ in
            if let completion = completion {
                DispatchQueue.main.async { () -> Void in
                    completion()
                }
            }
        })
    }
    
    static func latestAnswers() {
        downloadToJSONArray(JsonAPI.qAp, arrayNode: "answers", conversionBlock: { (context, JSONArray) -> () in
            var count = 0
            for JSONModel in JSONArray {
                let article = try Answer.decodeJSON(JSONModel, context: context)
                if article.objectID.isTemporaryID {
                    //Then the object isn't persisted yet
                    count += 1
                }
            }
            if count == JSONArray.count {
                //Then All of the objects are new... lets DOWNLOAD ALL THE ANSWERS
                DispatchQueue.main.async { () -> Void in
                    allTheAnswers()
                }
            }
        })
    }
    
    static func allTheAnswers(_ completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.qa, arrayNode: "answers", conversionBlock: { (context, JSONArray) -> () in
            let existingAnswers: [Answer] = Answer.findAll(context)
            
            var existingAnswerIds = Set<String>(existingAnswers.map( { $0.identifier } ))
            
            for JSONModel in JSONArray {
                let answer = try Answer.decodeJSON(JSONModel, context: context)
                let _ = existingAnswerIds.remove(answer.identifier)
            }
            
            if existingAnswerIds.count > 0 {
                let answerToDelete: [Answer] = Answer.findAllWithPredicate(NSPredicate(format: "%K in %@", AnswerAttributes.identifier.rawValue, existingAnswerIds), context: context)
                
                answerToDelete.forEach({ (article) in
                    context.delete(article)
                })
            }
            
            if let completion = completion {
                DispatchQueue.main.async { () -> Void in
                    completion()
                }
            }
        })
    }
    
    static func allTheChannels() {
        downloadToJSONArray(JsonAPI.channels, arrayNode: "channels", conversionBlock: { (context, JSONArray) in
            let existingChannels: [Channel] = Channel.findAll(context)
            var existingChannelIds = Set<String>(existingChannels.map({ $0.identifier }))
                        
            try JSONArray.enumerated().forEach({ (index, channelDict) in
                let channel = try Channel.decodeJSON(channelDict, context: context, index: index)
                existingChannelIds.remove(channel.identifier)
            })
            
            if existingChannelIds.count > 0 {
                let channelsToDelete: [Channel] = Channel.findAllWithPredicate(NSPredicate(format: "%K in %@", ChannelAttributes.identifier.rawValue, existingChannelIds), context: context)
                
                channelsToDelete.forEach({
                    context.delete($0)
                })
            }
            
            let orphanedVideos = Video.findAllWithPredicate(NSPredicate(format: "%K == NULL", VideoRelationships.channel.rawValue), context: context)
            
            orphanedVideos.forEach({ (video) in
                context.delete(video)
            })
        })
    }
    
    static func allTheCurriculums() {
        downloadToJSONArray(JsonAPI.curriculum, arrayNode: "curriculum", conversionBlock:  { (context, JSONArray) in
            
        })
    }
    
    static func allTheEvents() {
        downloadToJSONArray(JsonAPI.events, arrayNode: "events", conversionBlock: { (context, JSONArray) in
            
            let existingEvents: [Event] = Event.findAll(context)
            var existingEventIds = existingEvents.map({ (event) -> String in
                return event.identifier
            })
            
            try JSONArray.enumerated().forEach({ (index, eventDict) in
                let event = try Event.decodeJSON(eventDict, context: context, index: index)
                if let index = existingEventIds.index(of: event.identifier) {
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
        })
    }
    
    
    fileprivate static func downloadToJSONArray(_ request: JsonAPI, arrayNode: String? = nil, conversionBlock: @escaping (_ context: NSManagedObjectContext, _ JSONArray: [[AnyHashable: Any]]) throws ->(), completion: ((Error?)->())? = nil) {
        Provider.sharedProvider.request(request) { (result) -> () in
            switch result {
            case .success(let response):
                DispatchQueue.global(qos: .background).async {
                    //logger.info("🍕resonse: \(response)")
                    let data = response.data
                    
                    if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
                        let modelNodes: [[AnyHashable: Any]]
                        if let arrayNode = arrayNode, let result = json as? [AnyHashable : Any] {
                            modelNodes = result[arrayNode] as? [[AnyHashable: Any]] ?? []
                        } else {
                            modelNodes = json as? [[AnyHashable: Any]] ?? []
                        }
                        
                        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        context.parent = ContextCoordinator.sharedInstance.backgroundManagedObjectContext!
                        context.perform({ () -> Void in
                            do {
                                try conversionBlock(context, modelNodes)
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
                    }
                }
            case .failure(let error):
                logger.error("Error downloading articles P: \(error)")
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
