//
//  AudioContentManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/08/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData

class AudioContentManager: NSObject {

    static let sharedContentManager = AudioContentManager()
    private var audioCache: AudioPlayer?
    private var backgroundQueueContext: NSManagedObjectContext?
    
    private(set) var study: Study? //backgroundContext version
    private(set) var lesson: Lesson? //backgroundContext version
    
    override private init() {
        super.init()
    }
    
    func loadState(completion: (result: AudioResult)->()) {
        let context = ContextCoordinator.sharedInstance.backgroundManagedObjectContext
        backgroundQueueContext = context
        context.performBlock({
            self.audioCache = AudioPlayer.findFirst(context)
            if let audioCache = self.audioCache {
                let lesson = audioCache.lesson.first
                let study = audioCache.study.first
                
                if let lesson = lesson, study = study where lesson.audioProgress != 0 && lesson.audioProgress < 0.999 {
                    self.lesson = lesson
                    self.study = study
                    completion(result: AudioResult.Success)
                    return
                }
            } else {
                self.audioCache = AudioPlayer(managedObjectContext: context)
                self.audioCache?.currentTime = 0
                do {
                    try context.save()
                } catch let error {
                    log.error("Error saving: \(error)")
                }
            }
            completion(result: AudioResult.Error(error: AudioError.FailedToLoad))
        })
    }
    
    func prepareAudioManager(completion: (AudioResult)->()) {
        guard let lesson = lesson, study = study, backgroundQueueContext = backgroundQueueContext else {
            log.error("Lesson and Study are not ready to prepare audio manager")
            completion(AudioResult.Error(error: AudioError.UnknownException))
            return
        }
        
        backgroundQueueContext.performBlock { 
            if let audioURLString = lesson.audioSourceURL, url = APIDataManager.fileExists(lesson, urlString: audioURLString) {
                AudioManager.sharedInstance.loadAudio(atURL: url, completion: completion)
            } else {
                //probably want to download the file first
                ResourceManager.sharedInstance.startDownloading(lesson, resource: ResourceManager.LessonType.Audio, completion: { (result) in
                    switch result {
                    case .error(let error):
                        completion(AudioResult.Error(error: error)) //Pass the error on!
                    case .success(let lesson, let resource, let url):
                        AudioManager.sharedInstance.loadAudio(atURL: url, completion: completion)
                    }
                })
            }
        }
    }
    
    
    func configure(lessonID: NSManagedObjectID, studyID: NSManagedObjectID, completion: (AudioResult)->()) {
        backgroundQueueContext?.performBlock({
            self.study = backgroundQueueContext?.objectWithID(studyID)
            self.lesson = backgroundQueueContext?.objectWithID(lessonID)
            
            if let lesson = self.lesson {
                self.audioCache?.lessonIdentifier = self.lesson?.identifier
                self.audioCache?.studyIdentifier = self.study?.identifier
                self.audioCache?.currentTime = lesson.audioProgress
            }
            
            prepareAudioManager(completion)
        })
    }
    
    func presentController() {
        if (!NSThread.isMainThread()){
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.presentController()
            }
        }
        
        guard let lesson = lesson, study = study else {
            log.error("Lesson and Study are not ready to present controller")
            return
        }
        
        
        
        
    }
    
}
