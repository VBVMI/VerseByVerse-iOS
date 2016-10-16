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
    if string.characters.count > 0 {
        return string
    }
    return nil
}

protocol AssetsDownloadable {
    func directory() -> URL?
}

class APIDataManager {

    static func core() {
        downloadToJSONArray(.core, arrayNode: "studies") { (context, JSONArray) -> () in
            try JSONArray.enumerated().forEach({ (index, studyDict) in
                let _ = try Study.decodeJSON(studyDict, context: context, index: index)
            })
        }
    }
    
    static func lessons(_ studyID: String) {
        
        downloadToJSONArray(JsonAPI.lesson(identifier: studyID), arrayNode: "lessons") { (context, JSONModels) -> () in
            //We should fetch old lessons for merging and possible deletion
            let existingLessons = Lesson.findAllWithDictionary([LessonAttributes.studyIdentifier.rawValue: studyID], context: context) as? [Lesson] ?? []
            var existingLessonIds = existingLessons.map({ (lesson) -> String in
                return lesson.identifier
            })
            
            try JSONModels.enumerated().forEach({ (index, lessonDict) in
                let lesson = try Lesson.decodeJSON(lessonDict, studyID: studyID, context: context, index: index)
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
        }
    }
    
    static func latestArticles() {
        // download the articles P
        downloadToJSONArray(JsonAPI.articlesP, arrayNode: "articles") { (context, JSONModels) -> () in
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
        }
    }
    
    static func allTheArticles(_ completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.articles, arrayNode: "articles") { (context, JSONArray) -> () in
            for JSONModel in JSONArray {
                let _ = try Article.decodeJSON(JSONModel, context: context)
            }
            if let completion = completion {
                DispatchQueue.main.async { () -> Void in
                    completion()
                }
            }
            
        }
    }
    
    static func latestAnswers() {
        downloadToJSONArray(JsonAPI.qAp, arrayNode: "QandAPosts") { (context, JSONArray) -> () in
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
        }
    }
    
    static func allTheAnswers(_ completion:(()->())? = nil) {
        downloadToJSONArray(JsonAPI.qa, arrayNode: "QandAPosts") { (context, JSONArray) -> () in
            for JSONModel in JSONArray {
                let _ = try Answer.decodeJSON(JSONModel, context: context)
            }
            if let completion = completion {
                DispatchQueue.main.async { () -> Void in
                    completion()
                }
            }
        }
    }
    
    static func allTheChannels() {
        downloadToJSONArray(JsonAPI.channels, arrayNode: "channels") { (context, JSONArray) in
            
            try JSONArray.enumerated().forEach({ (index, channelDict) in
                let _ = try Channel.decodeJSON(channelDict, context: context, index: index)
            })
            
        }
    }
    
    static func allTheEvents() {
        downloadToJSONArray(JsonAPI.events, arrayNode: "events") { (context, JSONArray) in
            
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
        }
    }
    
    
    fileprivate static func downloadToJSONArray(_ request: JsonAPI, arrayNode: String, conversionBlock: @escaping (_ context: NSManagedObjectContext, _ JSONArray: [NSDictionary]) throws ->()) {
        Provider.sharedProvider.request(request) { (result) -> () in
            switch result {
            case .success(let response):
                DispatchQueue.global(qos: .background).async {
                    //log.info("resonse: \(response)")
                    let data = response.data
                    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    
                    if let json = json {
                        do {
                            let result = try NSDictionary.decode(json)
                            if let vbvmi = result["VerseByVerse"] as? NSDictionary, let modelNodes = vbvmi[arrayNode] as? Array<NSDictionary> {
                                
                                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                                context.parent = ContextCoordinator.sharedInstance.backgroundManagedObjectContext!
                                context.perform({ () -> Void in
                                    do {
                                        try conversionBlock(context, modelNodes)
                                    } catch let error {
                                        log.error("Error decoding modelJSON \(error)")
                                    }
                                    
                                    do {
                                        if context.hasChanges {
                                            try context.save()
                                        }
                                        ContextCoordinator.sharedInstance.backgroundManagedObjectContext!.perform({ () -> Void in
                                            do {
                                                try ContextCoordinator.sharedInstance.backgroundManagedObjectContext!.save()
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
            case .failure(let error):
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
