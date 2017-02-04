//
//  ResourceManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

enum ResourceManagerError : Error {
    case missingURLString
}

protocol ResourceManagerObserver: NSObjectProtocol {
    
    func downloadStateChanged(_ lesson: Lesson, lessonType: ResourceManager.LessonType, downloadState: ResourceManager.DownloadState)
    
}

/**
 *  The purpose of the resource manager is to provide a cool way to download and manage resources, to be updated about download progress, and to make it easy to know general stuff, like which is better: tabs or spaces
    - warning: `ResourceManager` is not thread safe. It must always be called from the main thread.
 */
class ResourceManager {
    
    static let sharedInstance = ResourceManager()
    
    fileprivate init() {
        
    }
    
    enum FileType : Int {
        case pdf
        case audio
        case video
    }
    
    enum LessonType : Int {
        case video
        case teacherAid
        case studentAid
        case transcript
        case audio
        
        static var all: [LessonType] = [.video, .teacherAid, .studentAid, .transcript, .audio]
        fileprivate static var downloadable: [LessonType] = [.teacherAid, .studentAid, .transcript, .audio]
        
        func urlString(_ lesson: Lesson) -> String? {
            switch self {
            case .audio:
                return lesson.audioSourceURL
            case .studentAid:
                return lesson.studentAidURL
            case .teacherAid:
                return lesson.teacherAid
            case .transcript:
                return lesson.transcriptURL
            case .video:
                return lesson.videoSourceURL
            }
        }
        
        func fileType() -> FileType {
            switch self {
            case .audio:
                return .audio
            case .video:
                return .video
            default:
                return .pdf
            }
        }
        
        var title: String {
            switch self {
            case .audio:
                return "Audio"
            case .studentAid:
                return "Slides"
            case .teacherAid:
                return "Handout"
            case .transcript:
                return "Transcript"
            case .video:
                return "Video"
            }
        }
    }
    
    enum DownloadState {
        case pending    /// Download has started but we haven't received a response yet
        case downloading(percent: Double) /// Download has started
        case downloaded(url: URL) /// File is downloaded
        case nothing /// File is not downloaded, and we are not trying to download it yet
    }
    
    enum DownloadResult {
        case error(error: Error)
        case success(lesson: Lesson, resource: LessonType, url: URL)
    }
    
    
    fileprivate var observers = [ResourceManagerObserver]()
    fileprivate var currentOperations = [ResourceKey: Request]()
    
    fileprivate var state = [ResourceKey: DownloadState]()
    
    fileprivate struct ResourceKey : Hashable, CustomStringConvertible {
        var lessonIdentifier: String
        var lessonType: LessonType
        
        fileprivate var hashValue: Int {
            return "\(lessonIdentifier) - \(lessonType)".hashValue
        }
        
        var description: String {
            get {
                return "\(lessonIdentifier)-\(lessonType.title)"
            }
        }
    }
        
    /**
     Get all of the urls for downloaded files related to a lesson
     
     - parameter lesson: A lesson object
     */
    func downloadedFileUrls(_ lesson: Lesson) -> [URL] {
        let urls = ResourceManager.LessonType.all.flatMap({ $0.urlString(lesson) }).flatMap({ APIDataManager.fileExists(lesson, urlString: $0) })
        return urls
    }
    
    /**
     Add a download observer to be notified of changes to the download progress of any resource.
     
     - parameter observer: An observer
     */
    func addDownloadObserver(_ observer: ResourceManagerObserver) {
        guard Thread.isMainThread else {
            logger.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        observers.append(observer)
    }
    
    /**
     Remove a download observer
     
     - parameter observer: An observer
     */
    func removeDownloadObserver(_ observer: ResourceManagerObserver) {
        guard Thread.isMainThread else {
            logger.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        if let index = observers.index(where: { $0.isEqual(observer) }) {
            observers.remove(at: index)
        }
    }
    
    /**
     Get the current state of a lesson resource download
     
     - parameter lesson:   A `Lesson object
     - parameter resource: The resource to check
     
     - returns: The current `DownloadState`
     */
    func currentState(ofLesson lesson:Lesson, resource:  LessonType) -> DownloadState {
        guard Thread.isMainThread else {
            logger.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
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
    
    fileprivate func dispatchState(_ lesson: Lesson, resource: ResourceManager.LessonType, downloadState: ResourceManager.DownloadState) {
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
    func startDownloading(_ lesson: Lesson, resource: LessonType, completion: ((_ result: DownloadResult) -> ())? = nil) {
        guard Thread.isMainThread else {
            logger.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        
        guard let urlString = resource.urlString(lesson) else {
            completion?(DownloadResult.error(error: ResourceManagerError.missingURLString))
            return
        }
        
        if let url = URL(string: urlString) , !LessonType.downloadable.contains(resource) {
            completion?(DownloadResult.success(lesson: lesson, resource: resource, url: url))
            return
        }
        
        if let url = APIDataManager.fileExists(lesson, urlString: urlString) {
            completion?(DownloadResult.success(lesson: lesson, resource: resource, url: url))
        } else {
            
            let resourceKey = ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)
            var bgTask : UIBackgroundTaskIdentifier? = UIApplication.shared.beginBackgroundTask(withName: "ResourceDownload-\(resourceKey)", expirationHandler: {
                
                if let request = self.currentOperations.removeValue(forKey: resourceKey) {
                    request.cancel()
                }
            })
            if bgTask == UIBackgroundTaskInvalid {
                bgTask = nil
            }
            
            dispatchState(lesson, resource: resource, downloadState: .pending)
            let request = APIDataManager.downloadFile(lesson, urlString: urlString, progress: { (progress) -> () in
                DispatchQueue.main.async { () -> Void in
                    self.dispatchState(lesson, resource: resource, downloadState: .downloading(percent: progress.fractionCompleted))
                }
                }, completion: { (response) -> Void in
                    if let error = response.error {
                        logger.error("Error: \(error)")
                        self.dispatchState(lesson, resource: resource, downloadState: .nothing)
                    } else {
                        if let url = APIDataManager.fileExists(lesson, urlString: urlString) {
                            self.dispatchState(lesson, resource: resource, downloadState: .downloaded(url: url))
                            completion?(DownloadResult.success(lesson: lesson, resource: resource, url: url))
                        }
                    }
                    self.currentOperations[resourceKey] = nil
                    if let bgTask = bgTask {
                        UIApplication.shared.endBackgroundTask(bgTask)
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
    func cancelDownload(_ lesson: Lesson, resource: LessonType) {
        let resourceKey = ResourceKey(lessonIdentifier: lesson.identifier, lessonType: resource)
        if let request = currentOperations.removeValue(forKey: resourceKey) {
            request.cancel()
        }
    }
    
    
    /**
     Download all of the available resources for a Study. Note this should continue to run in the background and can be cancelled by any of the normal cancellation methods
     
     - parameter study:      The `Study` to download
     - parameter completion: A completion block for knowing when it's all done
     */
    func downloadAllResources(_ study: Study, completion: (()->())?) {
        guard Thread.isMainThread else {
            logger.error("\(#function) must be called from main thread. Unknown unsafe implications abound!")
            return
        }
        
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Lesson.entity(managedObjectContext: context)
        
        let sectionSort = NSSortDescriptor(key: LessonAttributes.completed.rawValue, ascending: true, selector: #selector(NSNumber.compare(_:)))
        let indexSort = NSSortDescriptor(key: LessonAttributes.lessonIndex.rawValue, ascending: true, selector: #selector(NSNumber.compare(_:)))
        
        fetchRequest.sortDescriptors = [sectionSort, indexSort]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", LessonAttributes.studyIdentifier.rawValue, study.identifier)
        
        if let lessons = try? context.fetch(fetchRequest) {
            downloadNextLesson(remainingLessons: lessons, completion: completion)
        }
    }
    
    fileprivate func downloadNextLesson(remainingLessons lessons: [Lesson], completion: (()->())?) {
        if lessons.count == 0 {
            completion?()
            return
        }
        
        var remainingLessons = lessons
        
        let lesson = remainingLessons.removeFirst()
        
        downloadAllResources(lesson) { 
            self.downloadNextLesson(remainingLessons: remainingLessons, completion: completion)
        }
        
    }
    
    fileprivate func downloadAllResources(_ lesson: Lesson, completion: (()->())?) {
        downloadNextResource(lesson, remainingResources: LessonType.downloadable, completion: completion)
    }
    
    fileprivate func downloadNextResource(_ lesson: Lesson, remainingResources resources: [LessonType], completion: (()->())?) {
        if resources.count == 0 {
            completion?()
            return
        }
        
        var remainingResources = resources
        
        var resource = remainingResources.removeFirst()
        while resource.urlString(lesson) == nil {
            if remainingResources.count == 0 {
                completion?()
                return
            }
            resource = remainingResources.removeFirst()
        }
        
        startDownloading(lesson, resource: resource) { (result) in
            self.downloadNextResource(lesson, remainingResources: remainingResources, completion: completion)
        }
    }
    
}

extension Lesson {
    open override func prepareForDeletion() {
        let urls = ResourceManager.sharedInstance.downloadedFileUrls(self)
        let fileManager = FileManager.default
        urls.forEach({ let _ = try? fileManager.removeItem(at: $0) })
        
        super.prepareForDeletion()
    }
}

private func ==(lhs: ResourceManager.ResourceKey, rhs: ResourceManager.ResourceKey) -> Bool {
    return lhs.lessonIdentifier == rhs.lessonIdentifier && lhs.lessonType == rhs.lessonType
}
