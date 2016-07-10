//
//  ResourceManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Alamofire

enum ResourceManagerError : ErrorType {
    case MissingURLString
}

protocol ResourceManagerObserver: NSObjectProtocol {
    
    func downloadStateChanged(lesson: Lesson, lessonType: ResourceManager.LessonType, downloadState: ResourceManager.DownloadState)
    
}

/**
 *  The purpose of the resource manager is to provide a cool way to download and manage resources, to be updated about download progress, and to make it easy to know general stuff, like which is better: tabs or spaces
    - warning: `ResourceManager` is not thread safe. It must always be called from the main thread.
 */
class ResourceManager {
    
    static let sharedInstance = ResourceManager()
    
    private init() {
        
    }
    
    enum FileType : Int {
        case PDF
        case Audio
        case Video
    }
    
    enum LessonType : Int {
        case Video
        case TeacherAid
        case StudentAid
        case Transcript
        case Audio
        
        static var all: [LessonType] = [.Video, .TeacherAid, .StudentAid, .Transcript, .Audio]
        
        func urlString(lesson: Lesson) -> String? {
            switch self {
            case .Audio:
                return lesson.audioSourceURL
            case .StudentAid:
                return lesson.studentAidURL
            case .TeacherAid:
                return lesson.teacherAid
            case .Transcript:
                return lesson.transcriptURL
            case .Video:
                return lesson.videoSourceURL
            }
        }
        
        func fileType() -> FileType {
            switch self {
            case .Audio:
                return .Audio
            case .Video:
                return .Video
            default:
                return .PDF
            }
        }
        
        var title: String {
            switch self {
            case .Audio:
                return "Audio"
            case .StudentAid:
                return "Slides"
            case .TeacherAid:
                return "Handout"
            case .Transcript:
                return "Transcript"
            case .Video:
                return "Video"
            }
        }
    }
    
    enum DownloadState {
        case pending    /// Download has started but we haven't received a response yet
        case downloading(percent: Double) /// Download has started
        case downloaded(url: NSURL) /// File is downloaded
        case nothing /// File is not downloaded, and we are not trying to download it yet
    }
    
    enum DownloadResult {
        case error(error: ErrorType)
        case success(lesson: Lesson, resource: LessonType, url: NSURL)
    }
    
    
    private var observers = [ResourceManagerObserver]()
    private var currentOperations = [ResourceKey: Request]()
    
    private var state = [ResourceKey: DownloadState]()
    
    private struct ResourceKey : Hashable, CustomStringConvertible {
        var lessonIdentifier: String
        var lessonType: LessonType
        
        private var hashValue: Int {
            return "\(lessonIdentifier) - \(lessonType)".hashValue
        }
        
        var description: String {
            get {
                return "\(lessonIdentifier)-\(lessonType.title)"
            }
        }
    }
    
    /**
     Add a download observer to be notified of changes to the download progress of any resource.
     
     - parameter observer: An observer
     */
    func addDownloadObserver(observer: ResourceManagerObserver) {
        guard NSThread.isMainThread() else {
            log.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        observers.append(observer)
    }
    
    /**
     Remove a download observer
     
     - parameter observer: An observer
     */
    func removeDownloadObserver(observer: ResourceManagerObserver) {
        guard NSThread.isMainThread() else {
            log.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        if let index = observers.indexOf({ $0.isEqual(observer) }) {
            observers.removeAtIndex(index)
        }
    }
    
    /**
     Get the current state of a lesson resource download
     
     - parameter lesson:   A `Lesson object
     - parameter resource: The resource to check
     
     - returns: The current `DownloadState`
     */
    func currentState(ofLesson lesson:Lesson, resource:  LessonType) -> DownloadState {
        guard NSThread.isMainThread() else {
            log.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return .nothing
        }
        
        if let resultState = state[ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)] {
            return resultState
        }
            
        guard let urlString = resource.urlString(lesson) else {
            state[ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)] = DownloadState.nothing
            return .nothing
        }
        
        if let url = APIDataManager.fileExists(lesson, urlString: urlString) {
            let value = DownloadState.downloaded(url: url)
            state[ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)] = value
            return value
        }
        
        return DownloadState.nothing
    }
    
    private func dispatchState(lesson: Lesson, resource: ResourceManager.LessonType, downloadState: ResourceManager.DownloadState) {
        state[ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)] = downloadState
        observers.forEach { (observer) in
            observer.downloadStateChanged(lesson, lessonType: resource, downloadState: downloadState)
        }
    }
    
    /**
     Start downloading a particular lesson resource and optionally add a completion block. Downloading will continue even while the application is backgrounded so don't even worry about it.
     
     - parameter lesson:     A `Lesson` object
     - parameter resource:   The resource type to download
     - parameter completion: If you just want to know how it all goes in the end.. Look no further
     */
    func startDownloading(lesson: Lesson, resource: LessonType, completion: ((result: DownloadResult) -> ())? = nil) {
        guard NSThread.isMainThread() else {
            log.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        
        guard let urlString = resource.urlString(lesson) else {
            completion?(result: DownloadResult.error(error: ResourceManagerError.MissingURLString))
            return
        }
        
        if let url = APIDataManager.fileExists(lesson, urlString: urlString) {
            completion?(result: DownloadResult.success(lesson: lesson, resource: resource, url: url))
        } else {
            
            let resourceKey = ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)
            var bgTask : UIBackgroundTaskIdentifier? = UIApplication.sharedApplication().beginBackgroundTaskWithName("ResourceDownload-\(resourceKey)", expirationHandler: {
                
                if let request = self.currentOperations.removeValueForKey(resourceKey) {
                    request.cancel()
                }
            })
            if bgTask == UIBackgroundTaskInvalid {
                bgTask = nil
            }
            
            dispatchState(lesson, resource: resource, downloadState: .pending)
            let request = APIDataManager.downloadFile(lesson, urlString: urlString, progress: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> () in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    let progress = Double(totalBytesRead) / Double(totalBytesExpectedToRead)
                    self.dispatchState(lesson, resource: resource, downloadState: .downloading(percent: progress))
                }
                }, completion: { (_, _, data, error) -> Void in
                    if let _ = data {
                        log.info("We have data")
                    }
                    if let error = error {
                        log.error("Error: \(error)")
                        self.dispatchState(lesson, resource: resource, downloadState: .nothing)
                    } else {
                        if let url = APIDataManager.fileExists(lesson, urlString: urlString) {
                            self.dispatchState(lesson, resource: resource, downloadState: .downloaded(url: url))
                            completion?(result: DownloadResult.success(lesson: lesson, resource: resource, url: url))
                        }
                    }
                    self.currentOperations[resourceKey] = nil
                    if let bgTask = bgTask {
                        UIApplication.sharedApplication().endBackgroundTask(bgTask)
                    }
                })
            self.currentOperations[resourceKey] = request
        }
    }
    
    /**
     Incase the `ResourceManager` is busy working on old things you no longer care about, you can cancel all of the ongoing downloads.
     */
    func cancelAllDownloads() {
        for (_, value) in self.currentOperations {
            value.cancel()
        }
        self.currentOperations.removeAll()
    }
    
    /**
     Cancel a single request
     
     - parameter lesson:   The `Lesson` instance
     - parameter resource: A resource
     */
    func cancelDownload(lesson: Lesson, resource: LessonType) {
        let resourceKey = ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)
        if let request = currentOperations.removeValueForKey(resourceKey) {
            request.cancel()
        }
    }
}

private func ==(lhs: ResourceManager.ResourceKey, rhs: ResourceManager.ResourceKey) -> Bool {
    return lhs.lessonIdentifier == rhs.lessonIdentifier && lhs.lessonType == rhs.lessonType
}
