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
    
    func button(_ cell: LessonTableViewCell) -> ACPDownloadView {
        switch self {
        case .audio:
            return cell.audioView.button
        case .studentAid:
            return cell.studentAidView.button
        case .teacherAid:
            return cell.teacherAidView.button
        case .transcript:
            return cell.transcriptView.button
        case .video:
            return cell.videoView.button
        }
    }
    
    func view(_ cell: LessonTableViewCell) -> ResourceIconView {
        switch self {
        case .audio:
            return cell.audioView
        case .studentAid:
            return cell.studentAidView
        case .teacherAid:
            return cell.teacherAidView
        case .transcript:
            return cell.transcriptView
        case .video:
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
    
    let videoView = ResourceIconView(frame: CGRect.zero)
    let teacherAidView = ResourceIconView(frame: CGRect.zero)
    let transcriptView = ResourceIconView(frame: CGRect.zero)
    let audioView = ResourceIconView(frame: CGRect.zero)
    let studentAidView = ResourceIconView(frame: CGRect.zero)
    @IBOutlet weak var resourcesStackView: UIStackView!
    
    fileprivate static let buttonFont = UIFont.fontAwesome(ofSize: 20)
    
    var urlButtonCallback: ((_ downloadView: ACPDownloadView, _ status: ACPDownloadStatus, _ buttonType: ResourceManager.LessonType) -> ())?
    
    let transcriptDownload = ACPDownloadView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resourcesStackView.addArrangedSubview(videoView)
        resourcesStackView.addArrangedSubview(teacherAidView)
        resourcesStackView.addArrangedSubview(studentAidView)
        resourcesStackView.addArrangedSubview(transcriptView)
        resourcesStackView.addArrangedSubview(audioView)
        
        videoView.isHidden = true
        teacherAidView.isHidden = true
        studentAidView.isHidden = true
        transcriptView.isHidden = true
        audioView.isHidden = true
        
        let buttonTintColor = StyleKit.darkGrey
        
        let videoImage = IconImages(string: String.fontAwesomeIcon(name: .youTubePlay))
        videoImage.strokeColor = buttonTintColor
        videoView.button.setImages(videoImage)
        videoView.button.tintColor = buttonTintColor
        videoView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .video)
        }
        let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.videoTap(_:)))
        videoView.addGestureRecognizer(videoTapGesture)
        
        let teacherAidImage = IconImages(string: String.fontAwesomeIcon(name: .fileO))
        teacherAidImage.strokeColor = buttonTintColor
        teacherAidView.button.setImages(teacherAidImage)
        teacherAidView.button.tintColor = buttonTintColor
        teacherAidView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .teacherAid)
        }
        let teacherAidGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.teacherAidTap(_:)))
        teacherAidView.addGestureRecognizer(teacherAidGesture)
        
        let studentAidImage = IconImages(string: String.fontAwesomeIcon(name: .filePowerpointO))
        studentAidImage.strokeColor = buttonTintColor
        studentAidView.button.setImages(studentAidImage)
        studentAidView.button.tintColor = buttonTintColor
        studentAidView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .studentAid)
        }
        let studentAidGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.studentAidTap(_:)))
        studentAidView.addGestureRecognizer(studentAidGesture)
        
        let transcriptImage = IconImages(string: String.fontAwesomeIcon(name: .fileTextO))
        transcriptImage.strokeColor = buttonTintColor
        transcriptView.button.setImages(transcriptImage)
        transcriptView.button.tintColor = buttonTintColor
        transcriptView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .transcript)
        }
        let transcriptGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.transcriptTap(_:)))
        transcriptView.addGestureRecognizer(transcriptGesture)
        
        let audioImage = IconImages(string: String.fontAwesomeIcon(name: .play))
        audioImage.strokeColor = buttonTintColor
        audioView.button.setImages(audioImage)
        audioView.button.tintColor = buttonTintColor
        audioView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .audio)
        }
        let audioGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.audioTap(_:)))
        audioView.addGestureRecognizer(audioGesture)
    
        descriptionLabel.textColor = StyleKit.midGrey
        timeLabel.textColor = StyleKit.midGrey
        
        progressIndicator.progressTintColor = StyleKit.lightGrey.withAlpha(0.2)
        progressIndicator.progress = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func audioTap(_ sender: AnyObject) {
        //audioButton.handleSingleTap
        urlButtonCallback?(audioView.button, audioView.button.currentStatus, .audio)
    }
    
    @IBAction func transcriptTap(_ sender: AnyObject) {
         urlButtonCallback?(transcriptView.button, transcriptView.button.currentStatus, .transcript)
    }
    
    @IBAction func studentAidTap(_ sender: AnyObject) {
         urlButtonCallback?(studentAidView.button, studentAidView.button.currentStatus, .studentAid)
    }
    
    @IBAction func teacherAidTap(_ sender: AnyObject) {
         urlButtonCallback?(teacherAidView.button, teacherAidView.button.currentStatus, .teacherAid)
    }
    
    @IBAction func videoTap(_ sender: AnyObject) {
         urlButtonCallback?(videoView.button, videoView.button.currentStatus, .video)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.isHidden = true
        teacherAidView.isHidden = true
        studentAidView.isHidden = true
        transcriptView.isHidden = true
        audioView.isHidden = true
    }
}
