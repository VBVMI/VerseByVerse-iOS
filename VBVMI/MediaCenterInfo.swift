//
//  MediaCenterInfo.swift
//  VBVMI
//
//  Created by Thomas Carey on 30/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaCenterInfo: NSObject, NSCoding {

    static let shared : MediaCenterInfo = {
//        if let filePath = filePath {
//            if let info = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.path) as? MediaCenterInfo {
//                info.configureInfo()
//                return info
//            }
//        }
        return MediaCenterInfo()
    }()
    
    private static let currentVersion = 1
    
    private static let filePath : URL? = {
        let fileManager = FileManager()
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        if let directory = urls.first {
            return directory.appendingPathComponent("_mediaCenterInfo")
        }
        return nil
    }()
    
    private var studyTitle: String?
    private var lessonTitle: String?
    private var duration : TimeInterval = 0
    private var playbackRate: Float = 0
    private var defaultPlaybackRate: Float = 0
    private var elapsedTime: TimeInterval = 0
    private var artwork : UIImage?
    
    private override init() {

        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        studyTitle = aDecoder.decodeObject(forKey: "studyTitle") as? String
        lessonTitle = aDecoder.decodeObject(forKey: "lessonTitle") as? String
        duration = aDecoder.decodeDouble(forKey: "duration")
        playbackRate = aDecoder.decodeFloat(forKey: "playbackRate")
        defaultPlaybackRate = aDecoder.decodeFloat(forKey: "defaultPlaybackRate")
        elapsedTime = aDecoder.decodeDouble(forKey: "elapsedTime")
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(MediaCenterInfo.currentVersion, forKey: "currentVersion")
        aCoder.encode(studyTitle, forKey: "studyTitle")
        aCoder.encode(lessonTitle, forKey: "lessonTitle")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(playbackRate, forKey: "playbackRate")
        aCoder.encode(defaultPlaybackRate, forKey: "defaultPlaybackRate")
        aCoder.encode(elapsedTime, forKey: "elapsedTime")
    }
    
    func configureInfo(studyTitle: String?, lessonTitle: String?, duration: TimeInterval, playbackRate: Float, defaultPlaybackRate: Float, elapsedTime: TimeInterval, artwork: UIImage?) {
        self.studyTitle = studyTitle
        self.lessonTitle = lessonTitle
        self.duration = duration
        self.playbackRate = playbackRate
        self.defaultPlaybackRate = defaultPlaybackRate
        self.elapsedTime = elapsedTime
        self.artwork = artwork
        
        configureInfo()
    }
    
    private func configureInfo() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        var info = [String: Any]()
        
        info[MPMediaItemPropertyAlbumTitle] = studyTitle
        info[MPMediaItemPropertyTitle] = lessonTitle
        info[MPMediaItemPropertyPlaybackDuration] = duration
        
        info[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = defaultPlaybackRate
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        if let artwork = artwork {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: artwork)
        }
        
        infoCenter.nowPlayingInfo = info
        
//        save()
    }
    
//    private func save() {
//        DispatchQueue(label: "MediaInfoCenter_Save_Queue").async {
//            if let filePath = MediaCenterInfo.filePath {
//                if NSKeyedArchiver.archiveRootObject(self, toFile: filePath.path) {
//                    logger.info("🍕Saved info to disk")
//                }
//            }
//        }
//    }
//    
//    func clearSavedData() {
//        DispatchQueue(label: "MediaInfoCenter_Delete_Queue").async {
//            if let filePath = MediaCenterInfo.filePath {
//                do {
//                    try FileManager().removeItem(at: filePath)
//                } catch let error {
//                    logger.error("🍕Couldn't delete the media info: \(error)")
//                }
//            }
//        }
//    }
}
