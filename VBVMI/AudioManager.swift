//
//  AudioPlayer.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/08/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager: NSObject {

    enum Mode {
        case Playing
        case Loading
        case Paused
        case Finished
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
    
    var audioIsReadyBlock: (()->())?
    
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
    
    func loadAudio(atURL URL:NSURL, progress: Double) {
        let asset = AVAsset(URL: URL)
        let item = AVPlayerItem(asset: asset)
        if mode == .Playing {
            stop(unregisterObservers: true)
        }
        
        startProgress = progress
        
        time = CMTimeMakeWithSeconds(position, 30)
        currentMonitoredItem = item
        avPlayer.replaceCurrentItemWithPlayerItem(item)
    }
    
    func start() {
        start(registerObservers: true)
    }
    
    private func start(registerObservers addObservers: Bool) -> Bool {
        
        if avPlayer.status != AVPlayerStatus.ReadyToPlay {
            log.error("avPlayer status is not readyToPlay")
            return false
        }
        
        let session = AVAudioSession.sharedInstance()
        if !setAudioSessionCategory() || !setAudioSessionMode() {
            return false
        }
        
        do {
            try session.setActive(true)
        } catch let error {
            log.error("Error activating audio session: \(error)")
            return false
        }
        
        if addObservers {
            registerObservers()
        }
        
        log.info("Starting audio player at rate \(playbackRate)")
        if let duration = avPlayer.currentItem?.duration where time >= duration {
            time = kCMTimeZero
            log.info("Resetting time to zero")
        }
        
        avPlayer.setRate(playbackRate, time: time, atHostTime: kCMTimeInvalid)
        
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
            log.error("Error deactivating audio session: \(error)")
        }
        
        if removeObservers {
            unregisterObservers()
        }
    }
    
    
    private func setAudioSessionCategory() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            log.error("Error setting AVAudioSession category: \(error)")
            return false
        }
        return true
    }
    
    private func setAudioSessionMode() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setMode(AVAudioSessionModeSpokenAudio)
        } catch let error {
            log.error("Error setting AVAudioSession category: \(error)")
            return false
        }
        return true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let _ = object as? AVPlayer where keyPath == "rate" {
            
        }
        if let item = object as? AVPlayerItem where keyPath == "status" {
            switch item.status {
            case .Failed:
                log.error("Failed to load audio: \(change)")
            case .ReadyToPlay:
                log.info("Ready to play")
                start(registerObservers: true)
            case .Unknown:
                log.info("Audio player state is unknown")
            }
        }
    }
    
    private func registerObservers() {
        let session = AVAudioSession.sharedInstance()
        audioInterruptionObserverToken = NSNotificationCenter.defaultCenter().addObserverForName(AVAudioSessionInterruptionNotification, object: session, queue: nil) { [weak self] (notification) in
            if let key = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSessionInterruptionType where key == .Began {
                self?.stop(unregisterObservers: false)
            } else {
                if self?.start(registerObservers: false) != true {
                    log.error("Couldn't restart after interruption")
                }
            }
        }
    }
    
    private func unregisterObservers() {
        if let token = audioInterruptionObserverToken {
            NSNotificationCenter.defaultCenter().removeObserver(token)
            audioInterruptionObserverToken = nil
        }
    }
}
