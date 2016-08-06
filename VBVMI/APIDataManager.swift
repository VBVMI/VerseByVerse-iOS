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
import SwiftString

enum APIDataManagerError : ErrorType {
    case MissingID
    case ModelCreationFailed
}

func nullOrString(str: String?) -> String? {
    guard let string = str else {
        return nil
    }
    if string.characters.count > 0 {
        return string
    }
    return nil
}

protocol AssetsDownloadable {
    func directory() -> NSURL?
}

class APIDataManager {

    static func core() {
        downloadToJSONArray(.Core, arrayNode: "studies") { (context, JSONArray) -> () in
            try JSONArray.enumerate().forEach({ (index, studyDict) in
                let _ = try Study.decodeJSON(studyDict, context: context, index: index)
            })
        }
    }
    
    static func lessons(studyID: String) {
        
        downloadToJSONArray(JsonAPI.Lesson(identifier: studyID), arrayNode: "lessons") { (context, JSONModels) -> () in
            //We should fetch old lessons for merging and possible deletion
            let existingLessons = Lesson.findAllWithDictionary([LessonAttributes.studyIdentifier.rawValue: studyID], context: context) as? [Lesson] ?? []
            var existingLessonIds = existingLessons.map({ (lesson) -> String in
                return lesson.identifier
            })
            
            try JSONModels.enumerate().forEach({ (index, lessonDict) in
                let lesson = try Lesson.decodeJSON(lessonDict, studyID: studyID, context: context, index: index)
                if let index = existingLessonIds.indexOf(lesson.identifier) {
                    existingLessonIds.removeAtIndex(index)
                }
            })
            
            if existingLessonIds.count > 0 {
                if let lessonsToDelete = Lesson.findAllWithPredicate(NSPredicate(format: "%K in %@", LessonAttributes.identifier.rawValue, existingLessonIds), context: context) as? [Lesson] where lessonsToDelete.count > 0 {
                    for lesson in lessonsToDelete {
                        context.deleteObject(lesson)
                    }
                }
            }
        }
    }
    
    static func latestArticles() {
        // download the articles P
        downloadToJSONArray(JsonAPI.ArticlesP, arrayNode: "articles") { (context, JSONModels) -> () in
            var count = 0
            for JSONModel in JSONModels {
                let article = try Article.decodeJSON(JSONModel, context: context)
                if article.objectID.temporaryID {
                    //Then the object isn't persisted yet
                    count += 1
                }
            }
            if count == JSONModels.count {
                //Then All of the objects are new... lets DOWNLOAD ALL THE ARTICLES
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    allTheArticles()
                }
            }
        }
    }
    
    static func allTheArticles(completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.Articles, arrayNode: "articles") { (context, JSONArray) -> () in
            for JSONModel in JSONArray {
                let _ = try Article.decodeJSON(JSONModel, context: context)
            }
            if let completion = completion {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    completion()
                }
            }
            
        }
    }
    
    static func latestAnswers() {
        downloadToJSONArray(JsonAPI.QAp, arrayNode: "QandAPosts") { (context, JSONArray) -> () in
            var count = 0
            for JSONModel in JSONArray {
                let article = try Answer.decodeJSON(JSONModel, context: context)
                if article.objectID.temporaryID {
                    //Then the object isn't persisted yet
                    count += 1
                }
            }
            if count == JSONArray.count {
                //Then All of the objects are new... lets DOWNLOAD ALL THE ANSWERS
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    allTheAnswers()
                }
            }
        }
    }
    
    static func allTheAnswers(completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.QA, arrayNode: "QandAPosts") { (context, JSONArray) -> () in
            for JSONModel in JSONArray {
                let _ = try Answer.decodeJSON(JSONModel, context: context)
            }
            if let completion = completion {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    completion()
                }
            }
        }
    }
    
    static func allTheChannels() {
        downloadToJSONArray(JsonAPI.Channels, arrayNode: "channels") { (context, JSONArray) in
            
            try JSONArray.enumerate().forEach({ (index, channelDict) in
                let _ = try Channel.decodeJSON(channelDict, context: context, index: index)
            })
            
        }
    }
    
    static func allTheEvents() {
        downloadToJSONArray(JsonAPI.Events, arrayNode: "events") { (context, JSONArray) in
            
            let existingEvents = Event.findAll(context) as? [Event] ?? [Event]()
            var existingEventIds = existingEvents.map({ (event) -> String in
                return event.identifier
            })
            
            try JSONArray.enumerate().forEach({ (index, eventDict) in
                let event = try Event.decodeJSON(eventDict, context: context, index: index)
                if let index = existingEventIds.indexOf(event.identifier) {
                    existingEventIds.removeAtIndex(index)
                }
            })
            
            if existingEventIds.count > 0 {
                if let eventsToDelete = Event.findAllWithPredicate(NSPredicate(format: "%K in %@", EventAttributes.identifier.rawValue, existingEventIds), context: context) as? [Lesson] where eventsToDelete.count > 0 {
                    for event in eventsToDelete {
                        context.deleteObject(event)
                    }
                }
            }
        }
    }
    
    
    private static func downloadToJSONArray(request: JsonAPI, arrayNode: String, conversionBlock: (context: NSManagedObjectContext, JSONArray: [NSDictionary]) throws ->()) {
        Provider.sharedProvider.request(request) { (result) -> () in
            switch result {
            case .Success(let response):
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    //log.info("resonse: \(response)")
                    let data = response.data
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    
                    if let json = json {
                        do {
                            let result = try NSDictionary.decode(json)
                            if let vbvmi = result["VerseByVerse"] as? NSDictionary, modelNodes = vbvmi[arrayNode] as? Array<NSDictionary> {
                                
                                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                                context.parentContext = ContextCoordinator.sharedInstance.backgroundManagedObjectContext
                                context.performBlock({ () -> Void in
                                    do {
                                        try conversionBlock(context: context, JSONArray: modelNodes)
                                    } catch let error {
                                        log.error("Error decoding modelJSON \(error)")
                                    }
                                    
                                    do {
                                        if context.hasChanges {
                                            try context.save()
                                        }
                                        ContextCoordinator.sharedInstance.backgroundManagedObjectContext.performBlock({ () -> Void in
                                            do {
                                                try ContextCoordinator.sharedInstance.backgroundManagedObjectContext.save()
                                            } catch (let error) {
                                                log.error("Error saving background context:\(error)")
                                            }
                                            
                                        })
                                    } catch (let error) {
                                        log.error("Error Saving: \(error)")
                                    }
                                })
                            }
                        } catch let error {
                            log.error("Error decoding article: \(error)")
                        }
                    }
                }
            case .Failure(let error):
                log.error("Error downloading articles P: \(error)")
            }
        }
    }
    
    /**
     Download a file to disk. The file path will be returned.
     
     - parameter urlString: The URL string for the file to be downloaded
     - parameter progress: The optional progress block
     - parameter completion: The completion block
     */
    static func downloadFile(model: AssetsDownloadable, urlString: String, progress: ((bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)->())?, completion: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void) -> Request {
        let destination : Alamofire.Request.DownloadFileDestination = { (temporaryURL, response) -> NSURL in
            if let directory = model.directory() {
                return directory.URLByAppendingPathComponent(response.suggestedFilename!)
            }
            return temporaryURL
        }
        
        return Alamofire.download(.GET, urlString, destination: destination).progress(progress).response(completionHandler: completion)
    }
    
    static func fileExists(model: AssetsDownloadable, urlString: String) -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        guard let getURL = NSURL(string: urlString) else { return nil }
        
        guard let url = model.directory(), fileName = getURL.lastPathComponent else { return nil }
        let fileURL  = url.URLByAppendingPathComponent(fileName)
        guard let path = fileURL.path else { return nil }
        
        if fileManager.fileExistsAtPath(path) {
            return fileURL
        }
        
        return nil
    }
}