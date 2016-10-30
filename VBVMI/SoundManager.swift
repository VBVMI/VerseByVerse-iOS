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
import Crashlytics

enum SoundError : Error, CustomNSError {
    case debug(message: String)
    
    var errorCode: Int {
        switch self {
        case .debug(_):
            return 0
        }
    }
    
    var errorUserInfo: [String : Any] {
        switch self {
        case .debug(let message):
            return ["debug": message]
        }
    }
    
    static var errorDomain: String = "com.versebyverseministry.SoundError"
}

class SoundManager: NSObject {

    static let sharedInstance = SoundManager()
    
    fileprivate(set) var study: Study? //backgroundContext version
    fileprivate(set) var lesson: Lesson? //backgroundContext version
    fileprivate(set) var lessonQueue = [Lesson]() //backgroundContext version
    
    fileprivate(set) var audioURL: URL?
    
    fileprivate var initialCategory: String?
    fileprivate var initialMode: String?
    
    let avPlayer = AVQueuePlayer()
    
    fileprivate var imageView = UIImageView()
    var albumCover: UIImage? {
        return imageView.image
    }
    
    fileprivate var audioCache: AudioPlayer?
    fileprivate var backgroundQueueContext: NSManagedObjectContext?
    
    fileprivate var playbackRate: Float = AudioPlayerViewController.AudioRate.load().rawValue
    
    fileprivate var initializeCompletionHandler: ((NSError?) -> Void)?
    fileprivate var initiatePlaybackCompletionHandler: ((NSError?) -> Void)?
    weak var activeController: UIViewController?
    
    fileprivate var currentMonitoredItem: AVPlayerItem? {
        didSet {
            if let old = oldValue {
                old.removeObserver(self, forKeyPath: "status")
            }
            if let new = currentMonitoredItem {
                new.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            }
        }
    }
    
    fileprivate var timerObserver : AnyObject?
    fileprivate override init() {
        super.init()
        startTimerObserver()
        
        self.configureCommandCenter()
        self.restoreState()
        self.configureContentManager()
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinish(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    deinit {
        self.avPlayer.removeObserver(self, forKeyPath: "rate")
        self.currentMonitoredItem = nil
        stopTimerObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    func audioDidFinish(_ notification: Notification) {
        //Mark the lesson as complete
        backgroundQueueContext?.perform({ () -> Void in
            self.lesson?.audioProgress = 0
            let _ = try? self.backgroundQueueContext?.save()
        })
        
    }
    
    fileprivate var isReady: Bool = false {
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? AVPlayer , keyPath == "rate" {
            self.configureInfo()
        }
        if let item = object as? AVPlayerItem , keyPath == "status" {
            if item.status == AVPlayerItemStatus.readyToPlay {
                logger.info("🍕Player became ready to play")
                let currentProgress = self.loadProgress
                
                let durationSeconds = CMTimeGetSeconds(item.duration)
                let progress = currentProgress * durationSeconds
                var time = CMTime(seconds: progress, preferredTimescale: item.duration.timescale)
                
                if time == kCMTimeInvalid {
                    logger.error("Time is invalid: progess: \(progress), timeScale: \(item.duration.timescale)")
                    time = kCMTimeZero
                }
                self.currentMonitoredItem = nil
                item.seek(to: time, completionHandler: { (sucess) in
                    logger.debug("Seek to time: \(sucess ? "Success" : "Failed")")
                    self.configureInfo()
                    self.isReady = true
                })
            }
        }
    }
    
    fileprivate func stopTimerObserver() {
        logger.info("🍕Sound Manager Stopping timer observer")
        if let timerObserver = timerObserver {
            self.avPlayer.removeTimeObserver(timerObserver)
            self.timerObserver = nil
        }
    }
    
    fileprivate func startTimerObserver() {
        logger.info("🍕Sound Manager Starting timer observer")
        self.timerObserver = self.avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 5, preferredTimescale: 600), queue: nil, using: { (currentTime) -> Void in
            self.saveState()
//            self.configureInfo()
//            logger.debug("Observing time: \(CMTimeGetSeconds(currentTime))")
        }) as AnyObject?
    }
    
    func restoreState(_ completion:(()->())? = nil) {
        isReady = false
        logger.verbose("Sound Manager Attempting To Restore State")
       
        let context = ContextCoordinator.sharedInstance.backgroundManagedObjectContext!
        self.backgroundQueueContext = context
        logger.verbose("Sound Manager has found context: \(context)")
        context.perform({ () -> Void in
            self.audioCache = AudioPlayer.findFirst(context)
            
            if self.audioCache == nil {
                
                self.audioCache = AudioPlayer(managedObjectContext: context)
                self.audioCache?.currentTime = 0
                
                do {
                    try context.save()
                } catch let error {
                    logger.error("Error saving: \(error)")
                }
            } else if let audioCache = self.audioCache {
                
                self.lesson = audioCache.lesson.first
                self.study = audioCache.study.first
                
                if let audioLesson = self.lesson, let audioStudy = self.study , audioLesson.audioProgress != 0 && audioLesson.audioProgress != 1 && audioLesson.audioProgress != 0 {
                    if let audioURLString = audioLesson.audioSourceURL {
                        if let url = APIDataManager.fileExists(audioLesson, urlString: audioURLString) {
                            // The file is downloaded and ready for playing
                            logger.verbose("Sound Manager State restored...")
                            let lessonId = audioLesson.objectID
                            let studyId = audioStudy.objectID
                            
                            DispatchQueue.main.async { () -> Void in
                               guard let mainLesson = ContextCoordinator.sharedInstance.managedObjectContext!.object(with: lessonId) as? Lesson,
                                let mainStudy = ContextCoordinator.sharedInstance.managedObjectContext!.object(with: studyId) as? Study else {
                                    return
                                }
                                //We should dispatch a notification to load the audio controller...
                                if let controller = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? HomeTabBarController {
                                    
                                    if let audioPlayerController = controller.popupContent as? AudioPlayerViewController {
                                        audioPlayerController.configure(url, name: mainLesson.title, subTitle: mainLesson.descriptionText ?? "", lesson: mainLesson, study: mainStudy)
                                        if controller.popupPresentationState == .closed {
                                            controller.openPopup(animated: true, completion: completion)
                                        }
                                    } else {
                                        let demoVC = AudioPlayerViewController()
                                        demoVC.configure(url, name: mainLesson.title, subTitle: mainLesson.descriptionText ?? "", lesson: mainLesson, study: mainStudy, startPlaying: false)
                                        
                                        controller.presentPopupBar(withContentViewController: demoVC, openPopup: true, animated: true, completion: completion)
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
    
    fileprivate var readyBlock: (()->())? = nil
    fileprivate var loadProgress: Double = 0 {
        didSet {
            logger.info("🍕Loading progress: \(self.loadProgress)")
        }
    }
    
    func configure(_ study: Study, lesson: Lesson, audioURL: URL, progress: Double = 0, readyBlock: (()->())? = nil) {
        isReady = false
        
        
        guard let context = backgroundQueueContext else {
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Sound Manager Background Context Not Configured"))
            logger.error("Sound Manager Background Context Not Configured")
            return
        }
        logger.info("🍕Sound Manager configuring with audio \(audioURL.lastPathComponent)")
        //convert the lesson and study into appropriate context objects
        self.loadProgress = progress == 1 ? 0 : progress
        
        context.performAndWait { () -> Void in
            do {
                self.study = try Study.withIdentifier(study.objectID, context: context)
                self.lesson = try Lesson.withIdentifier(lesson.objectID, context: context)
            } catch let error {
                logger.error("Error in SoundManager \(error)")
            }
        }
        
        self.audioURL = audioURL
        
        let asset = AVAsset(url: audioURL)
        
        let item = AVPlayerItem(asset: asset)
        self.currentMonitoredItem = item
        self.avPlayer.replaceCurrentItem(with: item)
        self.readyBlock = readyBlock
        
        getImage()
    }
    
    func startPlaying() {
//        logger.info("🍕Start playing")
////        if !audioSessionConfigured {
////            logger.error("Audio session not configured")
////            self.setupAudioSession({ (success) in
////                self.startPlaying()
////            })
////            return
////        }
//        if avPlayer.status == AVPlayerStatus.ReadyToPlay {
//            logger.info("🍕Playing audio")
//            avPlayer.setRate(playbackRate, time: kCMTimeInvalid, atHostTime: kCMTimeInvalid)
//            configureInfo()
//        } else {
//            logger.info("🍕AVPlayerStatus is not ready to play")
//        }
        
        let _ = start(registerObservers: true)
    }
    
    fileprivate func start(registerObservers addObservers: Bool) -> Bool {
        logger.info("🍕Starting AudioManager - addObservers:\(addObservers)")
        
        if avPlayer.status != AVPlayerStatus.readyToPlay {
            logger.error("avPlayer status is not readyToPlay")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "avPlayer status is not readyToPlay"))
            return false
        }
        
        let session = AVAudioSession.sharedInstance()
        if !setAudioSessionMode() || !setAudioSessionCategory() {
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Failed to configure Audio session"))
            logger.error("Failed to configure Audio session")
            return false
        }
        
        do {
            try session.setActive(true)
        } catch let error {
            logger.error("Error activating audio session: \(error)")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Error activating audio session: \(error)"))
            return false
        }
        
        if addObservers {
            registerObservers()
        }
        
        //        if let duration = avPlayer.currentItem?.duration {
        //            let seconds = CMTimeGetSeconds(duration)
        //            time = CMTimeMakeWithSeconds(seconds * progress, duration.timescale)
        //
        //        }
        //
        //        logger.info("🍕Starting audio player at rate \(playbackRate)")
        //        if let duration = avPlayer.currentItem?.duration where time >= duration {
        //            time = kCMTimeZero
        //            logger.info("🍕Resetting time to zero")
        //        }
        //
        //        avPlayer.setRate(playbackRate, time: time, atHostTime: kCMTimeInvalid)
        avPlayer.setRate(playbackRate, time: kCMTimeInvalid, atHostTime: kCMTimeInvalid)
        return true
    }
    
    func pausePlaying() {
        self.saveState()
        stop(unregisterObservers: true)
    }
    
    fileprivate func stop(unregisterObservers removeObservers: Bool) {
        avPlayer.pause()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error {
            logger.error("Error deactivating audio session: \(error)")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Error deactivating audio session: \(error)"))
        }
        
        if removeObservers {
            unregisterObservers()
        }
    }
    
    fileprivate func configureInfo() {
        let info = MediaCenterInfo.shared
        logger.info("🍕Configuring the info")
        
        guard let lesson = lesson, let study = study, let item = avPlayer.currentItem else {
            logger.warning("Trying to configure Sound Manager without all details")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Trying to configure Sound Manager without all details"), withAdditionalUserInfo: ["lesson": self.lesson != nil ? "valid": "invalid", "study": self.study != nil ? "valid": "invalid", "avPlayer.currentItem": avPlayer.currentItem != nil ? "valid": "invalid"])
            return
        }
        info.configureInfo(studyTitle: study.title, lessonTitle: lesson.title, duration: CMTimeGetSeconds(item.duration), playbackRate: self.avPlayer.rate, defaultPlaybackRate: self.playbackRate, elapsedTime: CMTimeGetSeconds(self.avPlayer.currentTime()), artwork: self.imageView.image)

    }
    
    fileprivate func configureContentManager() {
        
        logger.info("🍕Configure Content Manager")
        let manager = MPPlayableContentManager.shared()
        manager.delegate = self
        
    }

    
    fileprivate func configureCommandCenter() {
        logger.info("🍕Configuring command center")
//        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget (handler: { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let this = self else { return MPRemoteCommandHandlerStatus.commandFailed }
            // If no item, load the cached one
            if let item = this.avPlayer.currentItem {
                // If item is at end, and next is unavailable, error
                if CMTimeCompare(item.duration, this.avPlayer.currentTime()) <= 0 {
                    logger.verbose("Sound Manager Item is at end while trying to play")
                    Crashlytics.sharedInstance().recordError(SoundError.debug(message: "CC: Sound Manager Item is at end while trying to play"))
                    return .noSuchContent
                } else {
                    this.startPlaying()
                    this.configureInfo()
                    logger.verbose("Sound Manager Did Play")
                    return MPRemoteCommandHandlerStatus.success
                }
            } else {
                logger.verbose("Sound Manager Choosing to restore State then play")
                this.restoreState() {
                    this.startPlaying()
                    this.configureInfo()
                }
                return MPRemoteCommandHandlerStatus.success // ???
            }
        })
        
        commandCenter.togglePlayPauseCommand.addTarget (handler: { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let this = self else { return MPRemoteCommandHandlerStatus.commandFailed }
            if let item = this.avPlayer.currentItem {
                // If item is at end, and next is unavailable, error
                if CMTimeCompare(item.duration, this.avPlayer.currentTime()) <= 0 {
                    logger.verbose("Sound Manager Item is at end while trying to play")
                    Crashlytics.sharedInstance().recordError(SoundError.debug(message: "CC: Sound Manager Item is at end while trying to play"))
                    return .noSuchContent
                } else {
                    if this.avPlayer.rate == 0 {
                        //Player is stopped
                        this.startPlaying()
                        this.configureInfo()
                        logger.verbose("Sound Manager Did Play")
                        return MPRemoteCommandHandlerStatus.success
                    } else {
                        this.pausePlaying()
                        this.configureInfo()
                        logger.verbose("Sound Manager Did Pause")
                        return MPRemoteCommandHandlerStatus.success
                    }
                }
            } else {
                logger.verbose("Sound Manager Choosing to restore State then play")
                this.restoreState() {
                    this.startPlaying()
                    this.configureInfo()
                }
                return MPRemoteCommandHandlerStatus.success // ???
            }
            
        })
        
        commandCenter.pauseCommand.addTarget (handler: { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let this = self else { return MPRemoteCommandHandlerStatus.commandFailed }

            //Pause the player
            if let _ = this.avPlayer.currentItem {
                this.pausePlaying()
                
                logger.verbose("Sound Manager Did Pause audio")
//                this.configureInfo()
                return MPRemoteCommandHandlerStatus.success
            }
            logger.verbose("Sound Manager Failed Pause audio")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "CC: Sound Manager Failed Pause audio"))
            return MPRemoteCommandHandlerStatus.noSuchContent
            //save state
        })
        
        commandCenter.skipBackwardCommand.addTarget (handler: { (event) -> MPRemoteCommandHandlerStatus in
            if let skipEvent = event as? MPSkipIntervalCommandEvent , self.skipBackward(skipEvent.interval) {
                return .success
            }
            return .noSuchContent
        })
        commandCenter.skipBackwardCommand.preferredIntervals = [30]
        
        commandCenter.skipForwardCommand.addTarget (handler: { (event) -> MPRemoteCommandHandlerStatus in
            if let skipEvent = event as? MPSkipIntervalCommandEvent , self.skipForward(skipEvent.interval) {
                return .success
            }
            return .noSuchContent
        })
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.changePlaybackPositionCommand.addTarget (handler: { (event) -> MPRemoteCommandHandlerStatus in
            if let changeEvent = event as? MPChangePlaybackPositionCommandEvent {
                let timeStamp = changeEvent.positionTime
                if self.seekToTime(timeStamp) {
                    return .success
                } else {
                    return .noSuchContent
                }
            }
            return .commandFailed
        })
        
        commandCenter.nextTrackCommand.addTarget (handler: { (event) -> MPRemoteCommandHandlerStatus in
            logger.info("🍕Want to skip to next track?")
            return MPRemoteCommandHandlerStatus.noSuchContent
        })
    }

    func seekToTime(_ time: TimeInterval, completion:((_ success:Bool)->())? = nil) -> Bool {
        guard let currentItem = self.avPlayer.currentItem else {
            return false
        }
        let cmTime = self.avPlayer.currentTime()
        let totalTime = CMTimeGetSeconds(currentItem.duration)
        let skipToTime = max(0, min(totalTime, time))
        
        self.avPlayer.seek(to: CMTimeMakeWithSeconds(skipToTime, cmTime.timescale), completionHandler: { (success) -> Void in
            self.configureInfo()
            self.saveState()
            completion?(success)
        })
        return true
    }
    
    func skipForward(_ time: TimeInterval) -> Bool {
        logger.info("🍕Skip forward")
        guard let currentItem = self.avPlayer.currentItem else {
            return false
        }
        let interval = time
        let cmTime = self.avPlayer.currentTime()
        let currentTime = CMTimeGetSeconds(cmTime)
        let totalTime = CMTimeGetSeconds(currentItem.duration)
        let skipToTime = min(totalTime, currentTime + interval)
        self.avPlayer.seek(to: CMTimeMakeWithSeconds(skipToTime, cmTime.timescale), completionHandler: { (success) -> Void in
            self.configureInfo()
            self.saveState()
        })
        return true
    }
    
    func skipBackward(_ time: TimeInterval) -> Bool {
        logger.info("🍕Skip backward")
        let interval = time
        let cmTime = self.avPlayer.currentTime()
        let currentTime = CMTimeGetSeconds(cmTime)
        let skipToTime = max(0, currentTime - interval)
        self.avPlayer.seek(to: CMTimeMakeWithSeconds(skipToTime, cmTime.timescale), completionHandler: { (success) -> Void in
            self.configureInfo()
            self.saveState()
        })
        return true
    }
    
    fileprivate func saveState() {
        let duration = self.avPlayer.currentItem?.duration
        let currentTime = self.avPlayer.currentTime()
        
        backgroundQueueContext?.perform({ () -> Void in
            
            guard let audioCache = self.audioCache else {
                logger.error("There is no audio-cache for some reason")
                Crashlytics.sharedInstance().recordError(SoundError.debug(message: "There is no audio-cache for some reason"))
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
                    logger.debug("progress: \(self.lesson?.audioProgress)")
                }
            }
            
            do {
                try self.backgroundQueueContext?.save()
            } catch let error {
                logger.error("Error saving SoundManager state: \(error)")
                Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Error saving SoundManager state: \(error)"))
            }
        })
        
    }
    
    fileprivate var wasPlaying = false
    
    func handleInterruption(_ notification: Notification) {
        logger.info("🍕Handle interruption wasplaying: \(self.wasPlaying) notification: \(notification.userInfo)")
        guard let userInfo = (notification as NSNotification).userInfo as? [String: AnyObject] else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? AVAudioSessionInterruptionType else { return }
        
        switch type {
        case .began:
            logger.info("🍕Got interrupted")
            wasPlaying = true
        case .ended:
            if let flag = userInfo[AVAudioSessionInterruptionOptionKey] as? AVAudioSessionInterruptionOptions {
                if flag == .shouldResume && wasPlaying {
                    self.startPlaying()
                }
            }
        }
        
    }
    
    fileprivate var isObservingAudioSession = false
    fileprivate var audioSessionConfigured = false
    
    func handleNotification(_ notification: Notification) {
        logger.info("🍕\(notification.name) - \(notification.userInfo)")
    }
    
//    private func setupAudioSession(completion: ((success: Bool)->())?) {
//        logger.info("🍕Sound Manager Setting up Audio Session")
//        let audioSession = AVAudioSession.sharedInstance()
//        self.initialCategory = audioSession.category
//        self.initialMode = audioSession.mode
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            let success : Bool
//            do {
//                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
//                try audioSession.setMode(AVAudioSessionModeSpokenAudio)
//                
//                if !self.isObservingAudioSession {
//                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SoundManager.handleInterruption(_:)), name: AVAudioSessionInterruptionNotification, object: audioSession)
//                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SoundManager.handleNotification(_:)), name: AVAudioSessionMediaServicesWereLostNotification, object: audioSession)
//                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SoundManager.handleNotification(_:)), name: AVAudioSessionMediaServicesWereResetNotification, object: audioSession)
//                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SoundManager.handleNotification(_:)), name: AVAudioSessionSilenceSecondaryAudioHintNotification, object: audioSession)
//                    self.isObservingAudioSession = true
//                }
//
//                
//                try audioSession.setActive(true)
//                success = true
//                self.audioSessionConfigured = true
//            } catch let error {
//                logger.info("🍕error :\(error)")
//                success = false
//            }
//            if let completion = completion {
//                dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                    logger.info("🍕Sound Manager Completed Setup of Audio Session: \(success)")
//                    completion(success: success)
//                }
//            }
//        }
//    }
    
    fileprivate var audioInterruptionObserverToken : NSObjectProtocol? {
        didSet {
            if let oldValue = oldValue {
                NotificationCenter.default.removeObserver(oldValue)
            }
        }
    }
    
    fileprivate func registerObservers() {
        logger.info("🍕registering observers")
        let session = AVAudioSession.sharedInstance()
        audioInterruptionObserverToken = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVAudioSessionInterruption, object: session, queue: nil) { [weak self] (notification) in
            logger.info("🍕Interruption: \((notification as NSNotification).userInfo)")
            if let value = (notification as NSNotification).userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber {
                if let key = AVAudioSessionInterruptionType(rawValue: value.uintValue) , key == .began {
                    logger.info("🍕Began")
                    self?.stop(unregisterObservers: false)
                } else {
                    logger.info("🍕Ended")
                    if let option = (notification as NSNotification).userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber , option == NSNumber(value:AVAudioSessionInterruptionOptions.shouldResume.rawValue) {
                        if let this = self {
                            if this.start(registerObservers: false) != true {
                                logger.error("Couldn't restart after interruption")
                                Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Couldn't restart after interruption"))
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    fileprivate func setAudioSessionCategory() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            logger.error("Error setting AVAudioSession category: \(error)")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Error setting AVAudioSession category: \(error)"))
            return false
        }
        return true
    }
    
    fileprivate func setAudioSessionMode() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setMode(AVAudioSessionModeSpokenAudio)
        } catch let error {
            logger.error("Error setting AVAudioSession mode: \(error)")
            Crashlytics.sharedInstance().recordError(SoundError.debug(message: "Error setting AVAudioSession mode: \(error)"))
            return false
        }
        return true
    }
    
    fileprivate func unregisterObservers() {
        logger.info("🍕unregisering observers")
        if let token = audioInterruptionObserverToken {
            NotificationCenter.default.removeObserver(token)
            audioInterruptionObserverToken = nil
        }
    }
    
    fileprivate func getImage() {
        guard let thumbnailSource = study?.thumbnailSource, let url = URL(string: thumbnailSource) else {
            return
        }
        
        imageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false) { (response) -> Void in
            DispatchQueue.main.async {
                self.updateImage()
            }
            
            if let imageSource = self.study?.imageSource, let imageURL = URL(string: imageSource) {
                let image = self.imageView.image
                
                self.imageView.af_setImage(withURL: imageURL, placeholderImage: image, filter: nil, imageTransition: .noTransition, runImageTransitionIfCached: false) { (response) in
                    switch response.result {
                    case .failure(let error):
                        logger.error("Error download large image: \(error)")
                    case .success(let value):
                        self.imageView.image = value
                        DispatchQueue.main.async {
                            self.updateImage()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func updateImage() {
        configureInfo()
    }
    
    
    func setRate(_ value: Float) {
        playbackRate = value
        if avPlayer.rate != 0 {
            startPlaying()
        }
    }
}

extension SoundManager : MPPlayableContentDelegate {
    
    func playableContentManager(_ contentManager: MPPlayableContentManager, didUpdate context: MPPlayableContentManagerContext) {
        logger.debug("playableContentManager:didUpdateContext")
    }
    
    func playableContentManager(_ contentManager: MPPlayableContentManager, initializePlaybackQueueWithCompletionHandler completionHandler: @escaping (Error?) -> Void) {
        logger.debug("initializePlaybackQueueWithCompletionHandler")
        //Not sure about my understanding here. Seems that if you just call completionHandler(nil) then that means that you are good to go, and iOS will let you push info onto the command center
        if isReady {
            completionHandler(nil)
        } else {
            //content is loading so deal
            self.initializeCompletionHandler = completionHandler
        }
    }
    
    func playableContentManager(_ contentManager: MPPlayableContentManager, initiatePlaybackOfContentItemAt indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
        logger.debug("initiatePlaybackOfContentItemAtIndexPath - (\(indexPath.section),\(indexPath.row))")
        
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
