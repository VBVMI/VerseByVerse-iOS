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
    
    static func configure(_ cell: LessonTableViewCell, lesson: Lesson) {
        
        if let lessonNumber = lesson.lessonNumber , lessonNumber.count > 0 {
            cell.numberLabel.text = lessonNumber
            cell.numberLabel.isHidden = false
            cell.titleLabel.isHidden = true
        } else {
            cell.numberLabel.isHidden = true
            
            if lesson.title.count > 0 {
                cell.titleLabel.text = lesson.title
                cell.titleLabel.isHidden = false
            } else {
                cell.titleLabel.isHidden = true
            }
        }
        
        if let descriptionText = lesson.descriptionText , descriptionText.count > 0 {
            cell.descriptionLabel.text = descriptionText
            cell.descriptionLabel.isHidden = false
        } else {
            cell.descriptionLabel.isHidden = true
        }
        
        
        if let timeCode = lesson.audioLength , timeCode.count > 0 {
            cell.timeLabel.text = timeCode
            cell.timeLabel.isHidden = false
        } else {
            cell.timeLabel.isHidden = true
        }
        
        if let audioSource = lesson.audioSourceURL , audioSource.count > 10 {
            //might want to check that this makes a valid URL?
            cell.audioView.isHidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: audioSource) {
                cell.audioView.dotView.isHidden = false
            } else {
                cell.audioView.dotView.isHidden = true
            }
        } else {
            cell.audioView.isHidden = true
        }
        
        if let htmlTranscriptURL = lesson.transcriptHtmlURL, htmlTranscriptURL.count > 0 {
            cell.transcriptHTMLView.isHidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: htmlTranscriptURL) {
                cell.transcriptHTMLView.dotView.isHidden = false
            } else {
                cell.transcriptHTMLView.dotView.isHidden = true
            }
        } else {
            cell.transcriptHTMLView.isHidden = true
        }
        
        // Legacy fallback to PDF for lessons that aren't yet updated to have full size transcript
        if let transcript = lesson.transcriptURL , transcript.count > 10 {
            cell.transcriptPDFView.isHidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: transcript) {
                cell.transcriptPDFView.dotView.isHidden = false
            } else {
                cell.transcriptPDFView.dotView.isHidden = true
            }
            
        } else {
            cell.transcriptPDFView.isHidden = true
        }
        
        if let studentSourceURL = lesson.studentAidURL , studentSourceURL.count > 10 {
            //might want to check that this makes a valid URL?
            cell.studentAidView.isHidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: studentSourceURL) {
                cell.studentAidView.dotView.isHidden = false
            } else {
                cell.studentAidView.dotView.isHidden = true
            }
        } else {
            cell.studentAidView.isHidden = true
        }
        
        if let slidesURL = lesson.teacherAid , slidesURL.count > 10 {
            //might want to check that this makes a valid URL?
            cell.teacherAidView.isHidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: slidesURL) {
                cell.teacherAidView.dotView.isHidden = false
            } else {
                cell.teacherAidView.dotView.isHidden = true
            }
        } else {
            cell.teacherAidView.isHidden = true
        }
        
        
        if let videoURL = lesson.videoSourceURL , videoURL.count > 10 {
            //might want to check that this makes a valid URL?
            cell.videoView.isHidden = false
            
            if let _ = APIDataManager.fileExists(lesson, urlString: videoURL) {
                cell.videoView.dotView.isHidden = false
            } else {
                cell.videoView.dotView.isHidden = true
            }
        } else {
            cell.videoView.isHidden = true
        }
        
        cell.progressIndicator.setProgress(Float(lesson.audioProgress), animated: false)
        
        cell.audioView.button.setIndicatorStatus(.none)
        cell.teacherAidView.button.setIndicatorStatus(.none)
        cell.transcriptPDFView.button.setIndicatorStatus(.none)
        cell.transcriptHTMLView.button.setIndicatorStatus(.none)
        cell.videoView.button.setIndicatorStatus(.none)
        cell.studentAidView.button.setIndicatorStatus(.none)
    }
    
}
