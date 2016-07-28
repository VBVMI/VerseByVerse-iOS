//
//  SoundManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreData

class SoundManager: NSObject {

    static let sharedInstance = SoundManager()
    
    private(set) var study: Study? //backgroundContext version
    private(set) var lesson: Lesson? //backgroundContext version
    private(set) var lessonQueue = [Lesson]() //backgroundContext version
    
    private(set) var audioURL: NSURL?
    
    private var initialCategory: String?
    private var initialMode: String?
    
    let avPlayer = AVQueuePlayer()
    
    private var imageView = UIImageView()
    var albumCover: UIImage? {
        return imageView.image
    }
    
    private var audioCache: AudioPlayer?
    private var backgroundQueueContext: NSManagedObjectContext?
    
    private var playbackRate: Float = AudioPlayerViewController.AudioRate.load().rawValue
    
    private var initializeCompletionHandler: ((NSError?) -> Void)?
    private var initiatePlaybackCompletionHandler: ((NSError?) -> Void)?
    weak var activeController: UIViewController?
    
    private var currentMonitoredItem: AVPlayerItem? {
        didSet {
            if let old = oldValue {
                old.removeObserver(self, forKeyPath: "status")
            }
            if let new = currentMonitoredItem {
                new.addObserver(self, forKeyPath: "status", options: .New, context: nil)
            }
        }
    }
    
    private var timerObserver : AnyObject?
    private override init() {
        super.init()
        startTimerObserver()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.configureCommandCenter()
            self.restoreState()
            self.configureContentManager()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioDidFinish(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        self.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    deinit {
        self.avPlayer.removeObserver(self, forKeyPath: "rate")
        self.currentMonitoredItem = nil
        stopTimerObserver()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func audioDidFinish(notification: NSNotification) {
        //Mark the lesson as complete
        backgroundQueueContext?.performBlock({ () -> Void in
            self.lesson?.audioProgress = 0
            let _ = try? self.backgroundQueueContext?.save()
        })
        
    }
    
    private var isReady: Bool = false {
        didSet {
            if isReady {
                self.readyBlock?()
                self.readyBlock = nil
                self.initializeCompletionHandler?(nil)
                self.initializeCompletionHandler = nil
                self.initiatePlaybackCompletionHandler?(nil)
                self.initiatePlaybackCompletionHandler = nil
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let _ = object as? AVPlayer where keyPath == "rate" {
            self.configureInfo()
        }
        if let item = object as? AVPlayerItem where keyPath == "status" {
            if item.status == AVPlayerItemStatus.ReadyToPlay {
                
                let currentProgress = self.loadProgress
                
                let durationSeconds = CMTimeGetSeconds(item.duration)
                let progress = currentProgress * durationSeconds
                let time = CMTime(seconds: progress, preferredTimescale: item.duration.timescale)
                
                self.currentMonitoredItem = nil
                item.seekToTime(time, completionHandler: { (sucess) in
                    log.debug("Seek to time: \(sucess ? "Success" : "Failed")")
                    self.configureInfo()
                    self.isReady = true
                })
            }
        }
    }
    
    private func stopTimerObserver() {
        log.verbose("Sound Manager Stopping timer observer")
        if let timerObserver = timerObserver {
            self.avPlayer.removeTimeObserver(timerObserver)
            self.timerObserver = nil
        }
    }
    
    private func startTimerObserver() {
        log.verbose("Sound Manager Starting timer observer")
        self.timerObserver = self.avPlayer.addPeriodicTimeObserverForInterval(CMTime(seconds: 5, preferredTimescale: 600), queue: nil, usingBlock: { (currentTime) -> Void in
            self.saveState()
//            self.configureInfo()
//            log.debug("Observing time: \(CMTimeGetSeconds(currentTime))")
        })
    }
    
    func restoreState(completion:(()->())? = nil) {
        isReady = false
        log.verbose("Sound Manager Attempting To Restore State")
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let context = delegate.backgroundManagedObjectContext
            self.backgroundQueueContext = context
            log.verbose("Sound Manager has found context: \(context)")
            context.performBlock({ () -> Void in
                self.audioCache = AudioPlayer.findFirst(context)
                
                if self.audioCache == nil {
                    
                    self.audioCache = AudioPlayer(managedObjectContext: context)
                    self.audioCache?.currentTime = 0
                    
                    do {
                        try context.save()
                    } catch let error {
                        log.error("Error saving: \(error)")
                    }
                } else if let audioCache = self.audioCache {
                    
                    self.lesson = audioCache.lesson.first
                    self.study = audioCache.study.first
                    
                    if let audioLesson = self.lesson, audioStudy = self.study where audioLesson.audioProgress != 0 && audioLesson.audioProgress != 1 && audioLesson.audioProgress != 0 {
                        if let audioURLString = audioLesson.audioSourceURL {
                            if let url = APIDataManager.fileExists(audioLesson, urlString: audioURLString) {
                                // The file is downloaded and ready for playing
                                log.verbose("Sound Manager State restored...")
                                let lessonId = audioLesson.objectID
                                let studyId = audioStudy.objectID
                                
                                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                   guard let mainLesson = delegate.managedObjectContext.objectWithID(lessonId) as? Lesson,
                                    mainStudy = delegate.managedObjectContext.objectWithID(studyId) as? Study else {
                                        return
                                    }
                                    //We should dispatch a notification to load the audio controller...
                                    if let controller = (UIApplication.sharedApplication().delegate as? AppDelegate)?.window?.rootViewController as? HomeTabBarController {
                                        
                                        if let audioPlayerController = controller.popupContentViewController as? AudioPlayerViewController {
                                            audioPlayerController.configure(url, name: mainLesson.title ?? "", subTitle: mainLesson.descriptionText ?? "", lesson: mainLesson, study: mainStudy)
                                            if controller.popupPresentationState == .Closed {
                                                controller.openPopupAnimated(true, completion: completion)
                                            }
                                        } else {
                                            let demoVC = AudioPlayerViewController()
                                            demoVC.configure(url, name: mainLesson.title ?? "", subTitle: mainLesson.descriptionText ?? "", lesson: mainLesson, study: mainStudy, startPlaying: false)
                                            
                                            controller.presentPopupBarWithContentViewController(demoVC, openPopup: true, animated: true, completion: completion)
                                        }
                                    }
                                }
                                //self.configure(study, lesson: lesson, audioURL: url, progress: lesson.audioProgress, readyBlock: completion)
                            } else {
                                // The file needs to be downloaded
                                // maybe? lets deal with this later?
                                
                            }
                        }
                    } else {
                        self.lesson = nil
                        self.study = nil
                        self.audioCache?.currentTime = 0
                    }
                }
            })
        }
    }
    
    private var readyBlock: (()->())? = nil
    private var loadProgress: Double = 0 {
        didSet {
            log.info("Loading progress: \(loadProgress)")
        }
    }
    
    func configure(study: Study, lesson: Lesson, audioURL: NSURL, progress: Double = 0, readyBlock: (()->())? = nil) {
        isReady = false
        guard let context = backgroundQueueContext else {
            log.error("Sound Manager Background Context Not Configured")
            return
        }
        log.verbose("Sound Manager configuring with audio \(audioURL.lastPathComponent)")
        //convert the lesson and study into appropriate context objects
        self.loadProgress = progress == 1 ? 0 : progress
        
        context.performBlockAndWait { () -> Void in
            do {
                self.study = try Study.withIdentifier(study.objectID, context: context)
                self.lesson = try Lesson.withIdentifier(lesson.objectID, context: context)
            } catch let error {
                log.error("Error in SoundManager \(error)")
            }
        }
        
        self.audioURL = audioURL
        
        setupAudioSession { (success) -> () in
            guard success else { return }
            
            let asset = AVAsset(URL: audioURL)
        
            let item = AVPlayerItem(asset: asset)
            self.currentMonitoredItem = item
            self.avPlayer.replaceCurrentItemWithPlayerItem(item)
            self.readyBlock = readyBlock
        }
        
        getImage()
        
    }
    
    func startPlaying() {
        avPlayer.setRate(playbackRate, time: kCMTimeInvalid, atHostTime: kCMTimeInvalid)
        configureInfo()
    }
    
    func pausePlaying() {
        self.saveState()
        avPlayer.pause()
        
    }
    
    private func configureInfo() {
        guard let lesson = lesson, study = study, item = avPlayer.currentItem else {
            log.warning("Trying to configure Sound Manager without all details")
            return
        }
        
        
        let infoCenter = MPNowPlayingInfoCenter.defaultCenter()
        var newInfo = [String: AnyObject]()
        
        newInfo[MPMediaItemPropertyAlbumTitle] = study.title
        newInfo[MPMediaItemPropertyTitle] = lesson.title
        newInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(item.duration)
        
        newInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.avPlayer.rate
        newInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = playbackRate
        newInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.avPlayer.currentTime())
        
        if let image = imageView.image {
            newInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        } else {
            newInfo[MPMediaItemPropertyArtwork] = nil
        }
        
        infoCenter.nowPlayingInfo = newInfo
    }
    
    private func configureContentManager() {
        
        
        let manager = MPPlayableContentManager.sharedContentManager()
        manager.delegate = self
        
    }

    
    private func configureCommandCenter() {
        log.info("Configuring command center")
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let this = self else { return MPRemoteCommandHandlerStatus.CommandFailed }
            // If no item, load the cached one
            if let item = this.avPlayer.currentItem {
                // If item is at end, and next is unavailable, error
                if CMTimeCompare(item.duration, this.avPlayer.currentTime()) <= 0 {
                    log.verbose("Sound Manager Item is at end while trying to play")
                    return .NoSuchContent
                } else {
                    this.startPlaying()
                    this.configureInfo()
                    log.verbose("Sound Manager Did Play")
                    return MPRemoteCommandHandlerStatus.Success
                }
            } else {
                log.verbose("Sound Manager Choosing to restore State then play")
                this.restoreState() {
                    this.startPlaying()
                    this.configureInfo()
                }
                return MPRemoteCommandHandlerStatus.Success // ???
            }
        }
        
        commandCenter.togglePlayPauseCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let this = self else { return MPRemoteCommandHandlerStatus.CommandFailed }
            if let item = this.avPlayer.currentItem {
                // If item is at end, and next is unavailable, error
                if CMTimeCompare(item.duration, this.avPlayer.currentTime()) <= 0 {
                    log.verbose("Sound Manager Item is at end while trying to play")
                    return .NoSuchContent
                } else {
                    if this.avPlayer.rate == 0 {
                        //Player is stopped
                        this.startPlaying()
                        this.configureInfo()
                        log.verbose("Sound Manager Did Play")
                        return MPRemoteCommandHandlerStatus.Success
                    } else {
                        this.pausePlaying()
                        this.configureInfo()
                        log.verbose("Sound Manager Did Pause")
                        return MPRemoteCommandHandlerStatus.Success
                    }
                }
            } else {
                log.verbose("Sound Manager Choosing to restore State then play")
                this.restoreState() {
                    this.startPlaying()
                    this.configureInfo()
                }
                return MPRemoteCommandHandlerStatus.Success // ???
            }
            
        }
        
        commandCenter.pauseCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let this = self else { return MPRemoteCommandHandlerStatus.CommandFailed }

            //Pause the player
            if let _ = this.avPlayer.currentItem {
                this.pausePlaying()
                
                log.verbose("Sound Manager Did Pause audio")
//                this.configureInfo()
                return MPRemoteCommandHandlerStatus.Success
            }
            log.verbose("Sound Manager Failed Pause audio")
            return MPRemoteCommandHandlerStatus.NoSuchContent
            //save state
        }
        
        commandCenter.skipBackwardCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            if let skipEvent = event as? MPSkipIntervalCommandEvent where self.skipBackward(skipEvent.interval) {
                return .Success
            }
            return .NoSuchContent
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [30]
        
        commandCenter.skipForwardCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            if let skipEvent = event as? MPSkipIntervalCommandEvent where self.skipForward(skipEvent.interval) {
                return .Success
            }
            return .NoSuchContent
        }
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.changePlaybackPositionCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            if let changeEvent = event as? MPChangePlaybackPositionCommandEvent {
                let timeStamp = changeEvent.positionTime
                let cmTime = self.avPlayer.currentTime()
                let totalTime = CMTimeGetSeconds(self.avPlayer.currentItem!.duration)
                let skipToTime = max(0, min(totalTime, timeStamp))

                self.avPlayer.seekToTime(CMTimeMakeWithSeconds(skipToTime, cmTime.timescale), completionHandler: { (success) -> Void in
                    self.configureInfo()
                    self.saveState()
                })
                return .Success
            }
            return .CommandFailed
        }
        
        commandCenter.nextTrackCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            log.info("Want to skip to next track?")
            return MPRemoteCommandHandlerStatus.NoSuchContent
        }
    }

    
    func skipForward(time: NSTimeInterval) -> Bool {
        guard let currentItem = self.avPlayer.currentItem else {
            return false
        }
        let interval = time
        let cmTime = self.avPlayer.currentTime()
        let currentTime = CMTimeGetSeconds(cmTime)
        let totalTime = CMTimeGetSeconds(currentItem.duration)
        let skipToTime = min(totalTime, currentTime + interval)
        self.avPlayer.seekToTime(CMTimeMakeWithSeconds(skipToTime, cmTime.timescale), completionHandler: { (success) -> Void in
            self.configureInfo()
            self.saveState()
        })
        return true
    }
    
    func skipBackward(time: NSTimeInterval) -> Bool {
        let interval = time
        let cmTime = self.avPlayer.currentTime()
        let currentTime = CMTimeGetSeconds(cmTime)
        let skipToTime = max(0, currentTime - interval)
        self.avPlayer.seekToTime(CMTimeMakeWithSeconds(skipToTime, cmTime.timescale), completionHandler: { (success) -> Void in
            self.configureInfo()
            self.saveState()
        })
        return true
    }
    
    private func saveState() {
        let duration = self.avPlayer.currentItem?.duration
        let currentTime = self.avPlayer.currentTime()
        
        backgroundQueueContext?.performBlock({ () -> Void in
            
            guard let audioCache = self.audioCache else {
                log.error("There is no audio-cache for some reason")
                return
            }
            
            audioCache.lessonIdentifier = self.lesson?.identifier
            audioCache.studyIdentifier = self.study?.identifier
            audioCache.currentTime = CMTimeGetSeconds(currentTime)
            
            //calculate progress for the lesson and store that!!
            if let duration = duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                let currentTimeSeconds = CMTimeGetSeconds(currentTime)
                if durationSeconds == 0 {
                    self.lesson?.audioProgress = 0
                } else {
                    self.lesson?.audioProgress = max(0, min(currentTimeSeconds / durationSeconds, 1))
                    log.debug("progress: \(self.lesson?.audioProgress)")
                }
            }
            
            do {
                try self.backgroundQueueContext?.save()
            } catch let error {
                log.error("Error saving SoundManager state: \(error)")
            }
        })
        
    }
    
    private func setupAudioSession(completion: ((success: Bool)->())?) {
        log.verbose("Sound Manager Setting up Audio Session")
        let audioSession = AVAudioSession.sharedInstance()
        self.initialCategory = audioSession.category
        self.initialMode = audioSession.mode
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let success : Bool
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setMode(AVAudioSessionModeSpokenAudio)
                try audioSession.setActive(true)
                success = true
            } catch let error {
                print("error :\(error)")
                success = false
            }
            if let completion = completion {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    log.verbose("Sound Manager Completed Setup of Audio Session: \(success)")
                    completion(success: success)
                }
            }
        }
    }
    
    private func restoreAudioSession(completion: ((success: Bool)->())?) {
        let audioSession = AVAudioSession.sharedInstance()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let success: Bool
            do {
                if let category = self.initialCategory {
                    try audioSession.setCategory(category)
                }
                if let mode = self.initialMode {
                    try audioSession.setMode(mode)
                }
                success = true
            } catch let error {
                log.error("Error restoring audio session: \(error)")
                success = false
            }
            if let completion = completion {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    completion(success: success)
                }
            }
        }
    }
    
    private func getImage() {
        guard let thumbnailSource = study?.thumbnailSource, url = NSURL(string: thumbnailSource) else {
            return
        }
        
        imageView.af_setImageWithURL(url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response) -> Void in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.updateImage()
            }
            
            if let imageSource = self.study?.imageSource, imageURL = NSURL(string: imageSource) {
                let image = self.imageView.image
                
                self.imageView.af_setImageWithURL(imageURL, placeholderImage: image, filter: nil, imageTransition: .None, runImageTransitionIfCached: false) { (response) in
                    switch response.result {
                    case .Failure(let error):
                        log.error("Error download large image: \(error)")
                    case .Success(let value):
                        self.imageView.image = value
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.updateImage()
                        }
                    }
                }
            }
        }
    }
    
    private func updateImage() {
        configureInfo()
    }
    
    
    func setRate(value: Float) {
        playbackRate = value
        if avPlayer.rate != 0 {
            startPlaying()
        }
    }
}

extension SoundManager : MPPlayableContentDelegate {
    
    func playableContentManager(contentManager: MPPlayableContentManager, didUpdateContext context: MPPlayableContentManagerContext) {
        log.debug("playableContentManager:didUpdateContext")
    }
    
    func playableContentManager(contentManager: MPPlayableContentManager, initializePlaybackQueueWithCompletionHandler completionHandler: (NSError?) -> Void) {
        log.debug("initializePlaybackQueueWithCompletionHandler")
        //Not sure about my understanding here. Seems that if you just call completionHandler(nil) then that means that you are good to go, and iOS will let you push info onto the command center
        if isReady {
            completionHandler(nil)
        } else {
            //content is loading so deal
            self.initializeCompletionHandler = completionHandler
        }
    }
    
    func playableContentManager(contentManager: MPPlayableContentManager, initiatePlaybackOfContentItemAtIndexPath indexPath: NSIndexPath, completionHandler: (NSError?) -> Void) {
        log.debug("initiatePlaybackOfContentItemAtIndexPath - (\(indexPath.section),\(indexPath.row))")
        
        if isReady {
            self.startPlaying()
            completionHandler(nil)
        } else {
            self.initiatePlaybackCompletionHandler = { [weak self] error in
                if error == nil {
                    self?.startPlaying()
                }
                completionHandler(error)
            }
        }
    }
}
