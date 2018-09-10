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
        case .transcriptPDF:
            return cell.transcriptPDFView.button
        case .video:
            return cell.videoView.button
        case .transcriptHTML:
            return cell.transcriptHTMLView.button
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
        case .transcriptPDF:
            return cell.transcriptPDFView
        case .video:
            return cell.videoView
        case .transcriptHTML:
            return cell.transcriptHTMLView
        }
    }
    
}

class LessonTableViewCell: UITableViewCell {

    enum CurrentState {
        case current
        case next
        case none
        
        var title: String? {
            switch self {
            case .current: return "RECENT"
            case .next: return "NEXT"
            case .none: return nil
            }
        }
        
        var isHidden: Bool {
            switch self {
            case .next, .current: return false
            case .none: return true
            }
        }
    }
    
    @IBOutlet private weak var flag: FlagView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet private weak var topStackView: UIStackView!
    
    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var currentState: CurrentState = .none {
        didSet {
            flag.isHidden = currentState.isHidden
            flag.title = currentState.title
        }
    }
    
    let videoView = ResourceIconView(frame: CGRect.zero)
    let teacherAidView = ResourceIconView(frame: CGRect.zero)
    let transcriptPDFView = ResourceIconView(frame: CGRect.zero)
    let audioView = ResourceIconView(frame: CGRect.zero)
    let studentAidView = ResourceIconView(frame: CGRect.zero)
    let transcriptHTMLView = ResourceIconView(frame: .zero)
    
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
        resourcesStackView.addArrangedSubview(transcriptPDFView)
        resourcesStackView.addArrangedSubview(transcriptHTMLView)
        resourcesStackView.addArrangedSubview(audioView)
        
        videoView.isHidden = true
        teacherAidView.isHidden = true
        studentAidView.isHidden = true
        transcriptPDFView.isHidden = true
        transcriptHTMLView.isHidden = true
        audioView.isHidden = true
        
        flag.isHidden = true
        
        topStackView.isLayoutMarginsRelativeArrangement = true
        topStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
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
        
        let transcriptPDFImage = IconImages(string: String.fontAwesomeIcon(name: .filePdfO))
        transcriptPDFImage.strokeColor = buttonTintColor
        transcriptPDFView.button.setImages(transcriptPDFImage)
        transcriptPDFView.button.tintColor = buttonTintColor
        transcriptPDFView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .transcriptPDF)
        }
        let transcriptPDFGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.transcriptPDFTap(_:)))
        transcriptPDFView.addGestureRecognizer(transcriptPDFGesture)
        
        let transcriptHTMLImage = IconImages(string: String.fontAwesomeIcon(name: .fileTextO))
        transcriptHTMLImage.strokeColor = buttonTintColor
        transcriptHTMLView.button.setImages(transcriptHTMLImage)
        transcriptHTMLView.button.tintColor = buttonTintColor
        transcriptHTMLView.button.setActionForTap { [weak self] (view, status) -> Void in
            self?.urlButtonCallback?(view!, status, .transcriptHTML)
        }
        let transcriptHTMLGesture = UITapGestureRecognizer(target: self, action: #selector(LessonTableViewCell.transcriptHTMLTap(_:)))
        transcriptHTMLView.addGestureRecognizer(transcriptHTMLGesture)
        
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
    
    @IBAction func transcriptHTMLTap(_ sender: AnyObject) {
         urlButtonCallback?(transcriptPDFView.button, transcriptHTMLView.button.currentStatus, .transcriptHTML)
    }
    
    @IBAction func transcriptPDFTap(_ sender: AnyObject) {
        urlButtonCallback?(transcriptPDFView.button, transcriptPDFView.button.currentStatus, .transcriptPDF)
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
        transcriptPDFView.isHidden = true
        audioView.isHidden = true
        transcriptHTMLView.isHidden = true
        currentState = .none
    }
}
