//
//  LessonCellViewModel.swift
//  VBVMI
//
//  Created by Thomas Carey on 27/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import ACPDownload

struct LessonCellViewModel {
    
    static func configure(cell: LessonTableViewCell, lesson: Lesson) {
        
        if let lessonNumber = lesson.lessonNumber where lessonNumber.characters.count > 0 {
            cell.numberLabel.text = lessonNumber
            cell.numberLabel.hidden = false
            cell.titleLabel.hidden = true
        } else {
            cell.numberLabel.hidden = true
            
            if lesson.title.characters.count > 0 {
                cell.titleLabel.text = lesson.title
                cell.titleLabel.hidden = false
            } else {
                cell.titleLabel.hidden = true
            }
        }
        
        if let descriptionText = lesson.descriptionText where descriptionText.characters.count > 0 {
            cell.descriptionLabel.text = descriptionText
            cell.descriptionLabel.hidden = false
        } else {
            cell.descriptionLabel.hidden = true
        }
        
        
        if let timeCode = lesson.audioLength where timeCode.characters.count > 0 {
            cell.timeLabel.text = timeCode
            cell.timeLabel.hidden = false
        } else {
            cell.timeLabel.hidden = true
        }
        
        if let audioSource = lesson.audioSourceURL where audioSource.characters.count > 10 {
            //might want to check that this makes a valid URL?
            cell.audioView.hidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: audioSource) {
                cell.audioView.dotView.hidden = false
            } else {
                cell.audioView.dotView.hidden = true
            }
        } else {
            cell.audioView.hidden = true
        }
        
        if let transcript = lesson.transcriptURL where transcript.characters.count > 10 {
            cell.transcriptView.hidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: transcript) {
                cell.transcriptView.dotView.hidden = false
            } else {
                cell.transcriptView.dotView.hidden = true
            }
            
        } else {
            cell.transcriptView.hidden = true
        }
        
        if let studentSourceURL = lesson.studentAidURL where studentSourceURL.characters.count > 10 {
            //might want to check that this makes a valid URL?
            cell.studentAidView.hidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: studentSourceURL) {
                cell.studentAidView.dotView.hidden = false
            } else {
                cell.studentAidView.dotView.hidden = true
            }
        } else {
            cell.studentAidView.hidden = true
        }
        
        if let slidesURL = lesson.teacherAid where slidesURL.characters.count > 10 {
            //might want to check that this makes a valid URL?
            cell.teacherAidView.hidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: slidesURL) {
                cell.teacherAidView.dotView.hidden = false
            } else {
                cell.teacherAidView.dotView.hidden = true
            }
        } else {
            cell.teacherAidView.hidden = true
        }
        
        
        if let videoURL = lesson.videoSourceURL where videoURL.characters.count > 10 {
            //might want to check that this makes a valid URL?
            cell.videoView.hidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: videoURL) {
                cell.videoView.dotView.hidden = false
            } else {
                cell.videoView.dotView.hidden = true
            }
        } else {
            cell.videoView.hidden = true
        }
        
        cell.progressIndicator.setProgress(Float(lesson.audioProgress), animated: false)
        
        cell.audioView.button.setIndicatorStatus(.None)
        cell.teacherAidView.button.setIndicatorStatus(.None)
        cell.transcriptView.button.setIndicatorStatus(.None)
        cell.videoView.button.setIndicatorStatus(.None)
        cell.studentAidView.button.setIndicatorStatus(.None)
    }
    
}
