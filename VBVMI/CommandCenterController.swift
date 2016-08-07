//
//  CommandCenterController.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/08/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import MediaPlayer

class CommandCenterController: NSObject {

    static let sharedController = CommandCenterController()
    
    override private init() {
        
    }
    
    private func configureCommandCenter() {
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
}
