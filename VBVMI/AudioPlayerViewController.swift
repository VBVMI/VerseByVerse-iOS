//
//  AudioPlayerViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 2/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreData

extension TimeInterval {
    
    var timeString: String {
        let totalSeconds = abs(Int(self))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds - (hours * 3600)) / 60
        let seconds = totalSeconds - (hours * 3600) - (minutes * 60)
        
        var str = self < 0 ? "-" : ""
        if hours > 0 {
            str += "\(hours):"
            str += minutes < 10 ? "0\(minutes):" : "\(minutes):"
            str += seconds < 10 ? "0\(seconds)" : "\(seconds)"
        } else {
            str += "\(minutes):"
            str += seconds < 10 ? "0\(seconds)" : "\(seconds)"
        }
        return str
    }
    
}

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var playlistButton: UIButton!
    @IBOutlet weak var jumpForwardButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var jumpBackButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    fileprivate var progressSliderDragging = false
    
    @IBOutlet weak var lowVolumeImageView: UIImageView!
    @IBOutlet weak var volumeView: VolumeView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var podcastName: String? {
        didSet {
            popupItem.title = podcastName
        }
    }
    
    var podcastSubTitle: String? {
        didSet {
            popupItem.subtitle = podcastSubTitle
        }
    }
    
    var initialCategory: String?
    
    var urlString: URL?
    var study: Study?
    var lesson: Lesson?
    
    var pauseBarButton: UIBarButtonItem!
    var playBarButton: UIBarButtonItem!
    var prevBarButton: UIBarButtonItem!
    var nextBarButton: UIBarButtonItem!
    var optionsBarButton: UIBarButtonItem!
    
    enum AudioRate : Float {
        case slow = 0.8
        case normal = 1.0
        case meduim = 1.2
        case fast = 1.5
    
        mutating func next() -> AudioRate {
            switch self {
            case .slow:
                self = .normal
            case .normal:
                self = .meduim
            case .meduim:
                self = .fast
            case .fast:
                self = .slow
            }
            return self
        }
        
        var title : String {
            if let rate = AudioRate.numberFormatter.string(from: NSNumber(self.rawValue)) {
                return "\(rate)x"
            }
            return "\(self.rawValue)x"
        }
        
        func save() {
            UserDefaults.standard.set(self.rawValue, forKey: "defaultAudioRate")
            UserDefaults.standard.synchronize()
        }
        
        static func load() -> AudioRate {
            let defaultValue = UserDefaults.standard.float(forKey: "defaultAudioRate")
            if let result = AudioRate(rawValue: defaultValue) {
                return result
            }
            return AudioRate.normal
        }
        
        fileprivate static let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 1
            return formatter
        }()
    }
    
    var audioRate: AudioRate = AudioRate.load()
    
    func configure(_ urlString: URL, name: String, subTitle: String, lesson: Lesson, study: Study, startPlaying: Bool = true) {
        self.podcastName = name
        self.podcastSubTitle = subTitle
        self.urlString = urlString
        self.study = study
        self.lesson = lesson
        
        configureViews()
        let progress = lesson.audioProgress == 1 ? 0 : lesson.audioProgress
        SoundManager.sharedInstance.configure(study, lesson: lesson, audioURL: urlString, progress: progress, readyBlock: { _ in
            if startPlaying {
                SoundManager.sharedInstance.startPlaying()
            }
        })
    }
    
    init() {
        
        super.init(nibName: "AudioPlayerViewController", bundle: nil)
        
        pauseBarButton = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(AudioPlayerViewController.playPauseToggle(_:)))
        playBarButton = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(AudioPlayerViewController.playPauseToggle(_:)))
        prevBarButton = UIBarButtonItem(image: UIImage(named: "prev"), style: .plain, target: self, action: #selector(AudioPlayerViewController.skipBackward(_:)))
        nextBarButton = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(AudioPlayerViewController.skipForward(_:)))
        optionsBarButton = UIBarButtonItem(image: UIImage(named: "action"), style: .plain, target: self, action: #selector(openPlayer(_:)))
        
        popupItem.subtitle = podcastSubTitle
        popupItem.title = podcastName
        
        
        layoutBarButtons()
        
        SoundManager.sharedInstance.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        
        SoundManager.sharedInstance.avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: DispatchQueue.main) { [weak self] (time) -> Void in
            guard self?.progressSliderDragging == false else { return }
            if let duration = SoundManager.sharedInstance.avPlayer.currentItem?.duration {
                let totalTime = CMTimeGetSeconds(duration)
                let currentTime = CMTimeGetSeconds(time)
                if totalTime > 0 {
                    let progress = Float(currentTime / totalTime)
                    self?.progressSlider.value = progress
                    self?.popupItem.progress = progress
                }
                if !currentTime.isNaN && !totalTime.isNaN {
                    let remainingTime = currentTime - totalTime
                    self?.endTimeLabel.text = remainingTime.timeString
                    self?.startTimeLabel.text = currentTime.timeString
                }
            } else {
                log.error("Couldn't get duration?")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinish(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func openPlayer(_ sender: AnyObject) {
        popupPresentationContainer?.openPopup(animated: true, completion: nil)
    }
    
    func audioDidFinish(_ notification: Notification) {
        //Mark the lesson as complete
        if let context = self.lesson?.managedObjectContext {
            context.perform({
                if Settings.sharedInstance.autoMarkLessonsComplete {
                    self.lesson?.completed = true
                    
                    // need to tell study to reload lessonCompletedCount
                    if let study = self.study {
                        let predicate = NSPredicate(format: "%K == %@", LessonAttributes.studyIdentifier.rawValue, study.identifier)
                        let lessons = Lesson.findAllWithPredicate(predicate, context: context) as! [Lesson]
                        
                        let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
                            return lesson.completed ? value + 1 : value
                        })
                        study.lessonsCompleted = Int32(lessonsCompleted)
                    }
                    
                }
                self.lesson?.audioProgress = 0
                log.debug("Finish progress: \(self.lesson?.audioProgress)")
                let _ = try? self.lesson?.managedObjectContext?.save()
            })
        }
        
        
        self.view.window?.rootViewController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    func layoutBarButtons() {
        if UIScreen.main.traitCollection.horizontalSizeClass == .regular {
            var leftItems : [UIBarButtonItem] = [prevBarButton]
            if SoundManager.sharedInstance.avPlayer.rate == 0 {
                leftItems.append(playBarButton)
            } else {
                leftItems.append(pauseBarButton)
            }
            leftItems.append(nextBarButton)
            self.popupItem.leftBarButtonItems = leftItems
            self.popupItem.rightBarButtonItems = [optionsBarButton]
        }
        else {
            if SoundManager.sharedInstance.avPlayer.rate == 0 {
                self.popupItem.leftBarButtonItems = [playBarButton]
            } else {
                self.popupItem.leftBarButtonItems = [pauseBarButton]
            }
            self.popupItem.rightBarButtonItems = [optionsBarButton]
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            // your custom implementation here
            layoutBarButtons()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    func configureViews() {
        guard imageView != nil else {
            return
        }
        if let thumbnailSource = study?.thumbnailSource {
            if let url = URL(string: thumbnailSource) {
                self.imageView.af_setImageWithURL(url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3)) { [weak self] (response) in
                    guard let this = self else { return }
                    switch response.result {
                    case .Failure(let error):
                        log.error("Error downloading thumbnail image: \(error)")
                    case .Success(let value):
                        this.imageView.image = value
                    }
                    
                    if let imageSource = this.study?.imageSource, let imageURL = NSURL(string: imageSource) {
                        let image = this.imageView.image
                        
                        this.imageView.af_setImageWithURL(imageURL, placeholderImage: this.imageView.image, filter: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3)) { [weak this] (response) in
                            guard let this = this else { return }
                            switch response.result {
                            case .Failure(let error):
                                log.error("Error download large image: \(error)")
                                this.imageView.image = image
                            case .Success(let value):
                                this.imageView.image = value
                            }
                        }
                    }
                }
            }
        }
        
        if let titleText = self.lesson?.title , titleText.characters.count > 0 {
            self.titleLabel.text = titleText
            self.titleLabel.isHidden = false
        } else {
            self.titleLabel.isHidden = true
        }
        
        if let descriptionText = self.lesson?.descriptionText , descriptionText.characters.count > 0 {
            self.descriptionLabel.text = descriptionText
            self.descriptionLabel.isHidden = false
        } else {
            self.descriptionLabel.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.restorationIdentifier = "AudioPlayerViewController"
        self.restorationClass = AudioPlayerViewController.self
        // Do any additional setup after loading the view.
        configureViews()
        //Configure the views
        
        let buttonFont = UIFont.fontAwesomeOfSize(20)
        self.playPauseButton.titleLabel?.font = buttonFont
        configurePlayPauseState()
        
        self.jumpForwardButton.setImage(StyleKit.imageOfForward, for: UIControlState())
        self.jumpBackButton.setImage(StyleKit.imageOfRollback, for: UIControlState())
        
        self.jumpBackButton.tintColor = StyleKit.darkGrey
        self.jumpForwardButton.tintColor = StyleKit.darkGrey
        
        self.jumpBackButton.contentMode = .center

        self.rateButton.setTitle(audioRate.title, for: UIControlState())
        self.rateButton.tintColor = StyleKit.darkGrey
        
        let otherFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        let font = UIFont.monospacedDigitSystemFont(ofSize: otherFont.pointSize, weight: UIFontWeightRegular)
        
        
        self.endTimeLabel.font = font
        self.startTimeLabel.font = font
        
        self.lowVolumeImageView.image = UIImage(named: "volDown")
//        self.highVolumeImageView.image = UIImage(named: "volUp")
        self.volumeView.tintColor = StyleKit.darkGrey
        
        self.volumeView.setRouteButtonImage(StyleKit.imageOfAirPlayCanvas, for: UIControlState())
        self.volumeView.showsRouteButton = true
        
        self.playPauseButton.tintColor = StyleKit.darkGrey
    }
    
    deinit {
        SoundManager.sharedInstance.avPlayer.removeObserver(self, forKeyPath: "rate")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer , keyPath == "rate" {
            self.configurePlayPauseState()
            layoutBarButtons()
            if let rate = AudioRate(rawValue: player.rate) {
                audioRate = rate
                self.rateButton.setTitle(rate.title, for: .normal)
            }
        }
    }
    
    fileprivate func configurePlayPauseState() {
        let isPlaying = SoundManager.sharedInstance.avPlayer.rate != 0
        if let button = self.playPauseButton {
            if isPlaying {
                button.setTitle(String.fontAwesomeIconWithName(.Pause), for: .normal)
            } else {
                button.setTitle(String.fontAwesomeIconWithName(.Play), for: .normal)
            }
        }
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playPauseToggle(_ sender: UIButton) {
        let isPlaying = SoundManager.sharedInstance.avPlayer.rate != 0
        if isPlaying {
            SoundManager.sharedInstance.pausePlaying()
        } else {
            SoundManager.sharedInstance.startPlaying()
        }
    }
    
    @IBAction func progressSliderEndTouches(_ sender: AnyObject) {
        if let duration = SoundManager.sharedInstance.avPlayer.currentItem?.duration {
            let timeInSeconds = CMTimeGetSeconds(duration)
            let finalTimeInSeconds = (Double( self.progressSlider.value ) * timeInSeconds)
            
            SoundManager.sharedInstance.seekToTime(finalTimeInSeconds) { (completed) in
                self.progressSliderDragging = false
            }
        }
    }
    
    @IBAction func progressSliderStartTouches(_ sender: AnyObject) {
        progressSliderDragging = true
    }

    @IBAction func skipForward(_ sender: AnyObject) {
        SoundManager.sharedInstance.skipForward(30)
    }
    
    @IBAction func skipBackward(_ sender: AnyObject) {
        SoundManager.sharedInstance.skipBackward(30)
    }
    
    @IBAction func toggleRate(_ sender: AnyObject) {
        audioRate.next().save()
        SoundManager.sharedInstance.setRate(audioRate.rawValue)
        rateButton.setTitle(audioRate.title, for: .normal)
    }
}

extension AudioPlayerViewController: UIViewControllerRestoration {
    static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        return AudioPlayerViewController(coder: coder)
    }
}
