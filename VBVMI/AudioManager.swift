//
//  AudioPlayer.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/08/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import AVFoundation

enum AudioError : ErrorType {
    case FailedToLoad
    case ItemInUnknownState
    
    case NotReady
    case AudioSessionNotConfigured
    case AudioSessionNotActive
    
    case UnknownException
}

enum AudioResult {
    case Error(error: ErrorType)
    case Success
}

class AudioManager: NSObject {

    enum Mode {
        case Playing
        case Loading
        case Ready
        case Paused
        case Finished
        case Error
    }
    
    static let sharedInstance = AudioManager()
    
    private var time: CMTime = kCMTimeInvalid
    private var startProgress: Double = 0
    
    private var audioInterruptionObserverToken : NSObjectProtocol? {
        didSet {
            if let oldValue = oldValue {
                NSNotificationCenter.defaultCenter().removeObserver(oldValue)
            }
        }
    }
    private var playbackRate: Float = AudioPlayerViewController.AudioRate.load().rawValue
    
    private var mode = Mode.Finished
    
    private var audioIsReadyBlock: ((_ result: AudioResult)->())?
    
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
    
    let avPlayer = AVQueuePlayer()
    
    private override init() {
        super.init()
        
        avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    deinit {
        avPlayer.removeObserver(self, forKeyPath: "rate")
        currentMonitoredItem = nil
        unregisterObservers()
    }
    
    func isPlaying() -> Bool {
        return avPlayer.rate != 0
    }
    
    func isReadyToPlay() -> Bool {
        return avPlayer.currentItem?.status == AVPlayerItemStatus.ReadyToPlay && !isPlaying()
    }
    
    func loadAudio(atURL URL:NSURL, completion: (_ result: AudioResult)->()) {
        let asset = AVAsset(URL: URL)
        let item = AVPlayerItem(asset: asset)
        if mode == .Playing {
            stop(unregisterObservers: true)
        }
        audioIsReadyBlock = completion
        currentMonitoredItem = item
        avPlayer.replaceCurrentItemWithPlayerItem(item)
    }
    
    func start(atProgress progress: Double = 0, completion: (_ result: AudioResult)->()) {
        start(registerObservers: true, progress: progress, completion: completion)
    }
    
    private func start(registerObservers addObservers: Bool, progress: Double, completion: ((_ result: AudioResult)->())? = nil) -> Bool {
        logger.info("🍕Starting AudioManager - addObservers:\(addObservers) - progress:\(progress)")
        
        if avPlayer.status != AVPlayerStatus.ReadyToPlay {
            logger.error("avPlayer status is not readyToPlay")
            completion?(result: AudioResult.Error(error: AudioError.NotReady))
            return false
        }
        
        let session = AVAudioSession.sharedInstance()
        if !setAudioSessionCategory() || !setAudioSessionMode() {
            completion?(result: AudioResult.Error(error: AudioError.AudioSessionNotConfigured))
            return false
        }
        
        do {
            try session.setActive(true)
        } catch let error {
            logger.error("Error activating audio session: \(error)")
            completion?(result: AudioResult.Error(error: AudioError.AudioSessionNotActive))
            return false
        }
        
        if addObservers {
            registerObservers()
        }
        
        if let duration = avPlayer.currentItem?.duration {
            
            let seconds = CMTimeGetSeconds(duration)
            time = CMTimeMakeWithSeconds(seconds * progress, duration.timescale)
            
        }
        
        logger.info("🍕Starting audio player at rate \(playbackRate)")
        if let duration = avPlayer.currentItem?.duration, time >= duration {
            time = kCMTimeZero
            logger.info("🍕Resetting time to zero")
        }
        
        mode = .Playing
        avPlayer.setRate(playbackRate, time: time, atHostTime: kCMTimeInvalid)
        completion?(result: AudioResult.Success)
        return true
    }
    
    func stop() {
        stop(unregisterObservers: true)
    }
    
    private func stop(unregisterObservers removeObservers: Bool) {
        avPlayer.pause()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error {
            logger.error("Error deactivating audio session: \(error)")
        }
        
        if removeObservers {
            unregisterObservers()
        }
        
        mode = .Paused
    }
    
    
    private func setAudioSessionCategory() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            logger.error("Error setting AVAudioSession category: \(error)")
            return false
        }
        return true
    }
    
    private func setAudioSessionMode() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setMode(AVAudioSessionModeSpokenAudio)
        } catch let error {
            logger.error("Error setting AVAudioSession category: \(error)")
            return false
        }
        return true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let _ = object as? AVPlayer, keyPath == "rate" {
            
        }
        if let item = object as? AVPlayerItem, keyPath == "status" {
            switch item.status {
            case .Failed:
                logger.error("Failed to load audio: \(change)")
                mode = .Error
                audioIsReadyBlock?(result: AudioResult.Error(error: AudioError.FailedToLoad))
            case .ReadyToPlay:
                logger.info("🍕Ready to play")
                mode = .Ready
                audioIsReadyBlock?(result: AudioResult.Success)
            case .Unknown:
                logger.info("🍕Audio player state is unknown")
                audioIsReadyBlock?(result: AudioResult.Error(error: AudioError.ItemInUnknownState))
            }
        }
    }
    
    private func registerObservers() {
        logger.info("🍕registering observers")
        let session = AVAudioSession.sharedInstance()
        audioInterruptionObserverToken = NSNotificationCenter.defaultCenter().addObserverForName(AVAudioSessionInterruptionNotification, object: session, queue: nil) { [weak self] (notification) in
            if let key = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSessionInterruptionType, key == .Began {
                self?.stop(unregisterObservers: false)
            } else {
                if let this = self {
                    if this.start(registerObservers: false, progress: CMTimeGetSeconds(this.time)) != true {
                        logger.error("Couldn't restart after interruption")
                        this.mode = .Error
                    }
                }
                
            }
        }
    }
    
    private func unregisterObservers() {
        logger.info("🍕unregisering observers")
        if let token = audioInterruptionObserverToken {
            NSNotificationCenter.defaultCenter().removeObserver(token)
            audioInterruptionObserverToken = nil
        }
    }
}
