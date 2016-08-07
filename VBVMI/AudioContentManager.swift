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
    
    func loadState(completion: ()->()) {
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
        })
    }
    
    func prepareAudioManager() {
        guard let lesson = lesson, study = study, backgroundQueueContext = backgroundQueueContext else {
            log.error("Lesson and Study are not ready to prepare audio manager")
            return
        }
        
        backgroundQueueContext.performBlock { 
            if let audioURLString = lesson.audioSourceURL, url = APIDataManager.fileExists(lesson, urlString: audioURLString) {
                
                AudioManager.sharedInstance.loadAudio(atURL: url, progress: lesson.audioProgress)
                
                
            } else {
                //probably want to download the file first ya?
            }
        }
        
        

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
