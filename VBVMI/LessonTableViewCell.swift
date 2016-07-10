//
//  LessonTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 25/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import FontAwesome_swift
import ACPDownload

extension ResourceManager.LessonType {
    
    func button(cell: LessonTableViewCell) -> ACPDownloadView {
        switch self {
        case .Audio:
            return cell.audioView.button
        case .StudentAid:
            return cell.studentAidView.button
        case .TeacherAid:
            return cell.teacherAidView.button
        case .Transcript:
            return cell.transcriptView.button
        case .Video:
            return cell.videoView.button
        }
    }
    
    func view(cell: LessonTableViewCell) -> ResourceIconView {
        switch self {
        case .Audio:
            return cell.audioView
        case .StudentAid:
            return cell.studentAidView
        case .TeacherAid:
            return cell.teacherAidView
        case .Transcript:
            return cell.transcriptView
        case .Video:
            return cell.videoView
        }
    }
    
}

class LessonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let videoView = ResourceIconView(frame: CGRectZero)
    let teacherAidView = ResourceIconView(frame: CGRectZero)
    let transcriptView = ResourceIconView(frame: CGRectZero)
    let audioView = ResourceIconView(frame: CGRectZero)
    let studentAidView = ResourceIconView(frame: CGRectZero)
    @IBOutlet weak var resourcesStackView: UIStackView!
    
    private static let buttonFont = UIFont.fontAwesomeOfSize(20)
    
    var urlButtonCallback: ((downloadView: ACPDownloadView, status: ACPDownloadStatus, buttonType: ResourceManager.LessonType) -> ())?
    
    let transcriptDownload = ACPDownloadView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resourcesStackView.addArrangedSubview(videoView)
        resourcesStackView.addArrangedSubview(teacherAidView)
        resourcesStackView.addArrangedSubview(studentAidView)
        resourcesStackView.addArrangedSubview(transcriptView)
        resourcesStackView.addArrangedSubview(audioView)
        
        videoView.hidden = true
        teacherAidView.hidden = true
        studentAidView.hidden = true
        transcriptView.hidden = true
        audioView.hidden = true
        
        let buttonTintColor = StyleKit.darkGrey
        
        let videoImage = IconImages(string: String.fontAwesomeIconWithName(.YouTubePlay))
        videoImage.strokeColor = buttonTintColor
        videoView.button.setImages(videoImage)
        videoView.button.tintColor = buttonTintColor
        videoView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(downloadView: view, status: status, buttonType: .Video)
        }
        let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.videoTap(_:)))
        videoView.addGestureRecognizer(videoTapGesture)
        
        let teacherAidImage = IconImages(string: String.fontAwesomeIconWithName(.FileO))
        teacherAidImage.strokeColor = buttonTintColor
        teacherAidView.button.setImages(teacherAidImage)
        teacherAidView.button.tintColor = buttonTintColor
        teacherAidView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(downloadView: view, status: status, buttonType: .TeacherAid)
        }
        let teacherAidGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.teacherAidTap(_:)))
        teacherAidView.addGestureRecognizer(teacherAidGesture)
        
        let studentAidImage = IconImages(string: String.fontAwesomeIconWithName(.FilePowerpointO))
        studentAidImage.strokeColor = buttonTintColor
        studentAidView.button.setImages(studentAidImage)
        studentAidView.button.tintColor = buttonTintColor
        studentAidView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(downloadView: view, status: status, buttonType: .StudentAid)
        }
        let studentAidGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.studentAidTap(_:)))
        studentAidView.addGestureRecognizer(studentAidGesture)
        
        let transcriptImage = IconImages(string: String.fontAwesomeIconWithName(.FileTextO))
        transcriptImage.strokeColor = buttonTintColor
        transcriptView.button.setImages(transcriptImage)
        transcriptView.button.tintColor = buttonTintColor
        transcriptView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(downloadView: view, status: status, buttonType: .Transcript)
        }
        let transcriptGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.transcriptTap(_:)))
        transcriptView.addGestureRecognizer(transcriptGesture)
        
        let audioImage = IconImages(string: String.fontAwesomeIconWithName(.Play))
        audioImage.strokeColor = buttonTintColor
        audioView.button.setImages(audioImage)
        audioView.button.tintColor = buttonTintColor
        audioView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(downloadView: view, status: status, buttonType: .Audio)
        }
        let audioGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.audioTap(_:)))
        audioView.addGestureRecognizer(audioGesture)
    
        descriptionLabel.textColor = StyleKit.midGrey
        timeLabel.textColor = StyleKit.midGrey
        
        progressIndicator.progressTintColor = StyleKit.lightGrey.colorWithAlpha(0.2)
        progressIndicator.progress = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func audioTap(sender: AnyObject) {
        //audioButton.handleSingleTap
        urlButtonCallback?(downloadView: audioView.button, status: audioView.button.currentStatus, buttonType: .Audio)
    }
    
    @IBAction func transcriptTap(sender: AnyObject) {
         urlButtonCallback?(downloadView: transcriptView.button, status: transcriptView.button.currentStatus, buttonType: .Transcript)
    }
    
    @IBAction func studentAidTap(sender: AnyObject) {
         urlButtonCallback?(downloadView: studentAidView.button, status: studentAidView.button.currentStatus, buttonType: .StudentAid)
    }
    
    @IBAction func teacherAidTap(sender: AnyObject) {
         urlButtonCallback?(downloadView: teacherAidView.button, status: teacherAidView.button.currentStatus, buttonType: .TeacherAid)
    }
    
    @IBAction func videoTap(sender: AnyObject) {
         urlButtonCallback?(downloadView: videoView.button, status: videoView.button.currentStatus, buttonType: .Video)
    }
}
