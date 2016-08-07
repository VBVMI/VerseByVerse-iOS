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


extension NSTimeInterval {
    
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
    private var progressSliderDragging = false
    
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
    
    var urlString: NSURL?
    var study: Study?
    var lesson: Lesson?
    
    var pauseBarButton: UIBarButtonItem!
    var playBarButton: UIBarButtonItem!
    var prevBarButton: UIBarButtonItem!
    var nextBarButton: UIBarButtonItem!
    var optionsBarButton: UIBarButtonItem!
    
    enum AudioRate : Float {
        case Slow = 0.8
        case Normal = 1.0
        case Meduim = 1.2
        case Fast = 1.5
    
        mutating func next() -> AudioRate {
            switch self {
            case .Slow:
                self = .Normal
            case .Normal:
                self = .Meduim
            case .Meduim:
                self = .Fast
            case .Fast:
                self = .Slow
            }
            return self
        }
        
        var title : String {
            if let rate = AudioRate.numberFormatter.stringFromNumber(self.rawValue) {
                return "\(rate)x"
            }
            return "\(self.rawValue)x"
        }
        
        func save() {
            NSUserDefaults.standardUserDefaults().setFloat(self.rawValue, forKey: "defaultAudioRate")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        static func load() -> AudioRate {
            let defaultValue = NSUserDefaults.standardUserDefaults().floatForKey("defaultAudioRate")
            if let result = AudioRate(rawValue: defaultValue) {
                return result
            }
            return AudioRate.Normal
        }
        
        private static let numberFormatter: NSNumberFormatter = {
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 1
            return formatter
        }()
    }
    
    var audioRate: AudioRate = AudioRate.load()
    
    func configure(urlString: NSURL, name: String, subTitle: String, lesson: Lesson, study: Study, startPlaying: Bool = true) {
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
        
        pauseBarButton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(AudioPlayerViewController.playPauseToggle(_:)))
        playBarButton = UIBarButtonItem(image: UIImage(named: "play"), style: .Plain, target: self, action: #selector(AudioPlayerViewController.playPauseToggle(_:)))
        prevBarButton = UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: self, action: #selector(AudioPlayerViewController.skipBackward(_:)))
        nextBarButton = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: self, action: #selector(AudioPlayerViewController.skipForward(_:)))
        optionsBarButton = UIBarButtonItem(image: UIImage(named: "action"), style: .Plain, target: self, action: #selector(openPlayer(_:)))
        
        popupItem.subtitle = podcastSubTitle
        popupItem.title = podcastName
        
        
        layoutBarButtons()
        
        SoundManager.sharedInstance.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
        
        SoundManager.sharedInstance.avPlayer.addPeriodicTimeObserverForInterval(CMTime(seconds: 1, preferredTimescale: 600), queue: dispatch_get_main_queue()) { [weak self] (time) -> Void in
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioDidFinish(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func openPlayer(sender: AnyObject) {
        popupPresentationContainerViewController?.openPopupAnimated(true, completion: nil)
    }
    
    func audioDidFinish(notification: NSNotification) {
        //Mark the lesson as complete
        self.lesson?.managedObjectContext?.performBlock({ 
            if Settings.sharedInstance.autoMarkLessonsComplete {
                self.lesson?.completed = true
            }
            self.lesson?.audioProgress = 0
            log.debug("Finish progress: \(self.lesson?.audioProgress)")
            let _ = try? self.lesson?.managedObjectContext?.save()
        })
        
        self.view.window?.rootViewController?.dismissPopupBarAnimated(true, completion: nil)
    }
    
    func layoutBarButtons() {
        if UIScreen.mainScreen().traitCollection.horizontalSizeClass == .Regular {
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

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            // your custom implementation here
            layoutBarButtons()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
    }
    
    func configureViews() {
        guard imageView != nil else {
            return
        }
        if let thumbnailSource = study?.thumbnailSource {
            if let url = NSURL(string: thumbnailSource) {
                self.imageView.af_setImageWithURL(url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3)) { [weak self] (response) in
                    guard let this = self else { return }
                    switch response.result {
                    case .Failure(let error):
                        log.error("Error downloading thumbnail image: \(error)")
                    case .Success(let value):
                        this.imageView.image = value
                    }
                    
                    if let imageSource = this.study?.imageSource, imageURL = NSURL(string: imageSource) {
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
        
        if let titleText = self.lesson?.title where titleText.characters.count > 0 {
            self.titleLabel.text = titleText
            self.titleLabel.hidden = false
        } else {
            self.titleLabel.hidden = true
        }
        
        if let descriptionText = self.lesson?.descriptionText where descriptionText.characters.count > 0 {
            self.descriptionLabel.text = descriptionText
            self.descriptionLabel.hidden = false
        } else {
            self.descriptionLabel.hidden = true
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
        
        self.jumpForwardButton.setImage(StyleKit.imageOfForward, forState: .Normal)
        self.jumpBackButton.setImage(StyleKit.imageOfRollback, forState: .Normal)
        
        self.jumpBackButton.tintColor = StyleKit.darkGrey
        self.jumpForwardButton.tintColor = StyleKit.darkGrey
        
        self.jumpBackButton.contentMode = .Center

        self.rateButton.setTitle(audioRate.title, forState: .Normal)
        self.rateButton.tintColor = StyleKit.darkGrey
        
        let otherFont = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        let font = UIFont.monospacedDigitSystemFontOfSize(otherFont.pointSize, weight: UIFontWeightRegular)
        
        
        self.endTimeLabel.font = font
        self.startTimeLabel.font = font
        
        self.lowVolumeImageView.image = UIImage(named: "volDown")
//        self.highVolumeImageView.image = UIImage(named: "volUp")
        self.volumeView.tintColor = StyleKit.darkGrey
        
        self.volumeView.setRouteButtonImage(StyleKit.imageOfAirPlayCanvas, forState: .Normal)
        self.volumeView.showsRouteButton = true
        
        self.playPauseButton.tintColor = StyleKit.darkGrey
    }
    
    deinit {
        SoundManager.sharedInstance.avPlayer.removeObserver(self, forKeyPath: "rate")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer where keyPath == "rate" {
            self.configurePlayPauseState()
            layoutBarButtons()
            if let rate = AudioRate(rawValue: player.rate) {
                audioRate = rate
                self.rateButton.setTitle(rate.title, forState: .Normal)
            }
        }
    }
    
    private func configurePlayPauseState() {
        let isPlaying = SoundManager.sharedInstance.avPlayer.rate != 0
        if let button = self.playPauseButton {
            if isPlaying {
                button.setTitle(String.fontAwesomeIconWithName(.Pause), forState: .Normal)
            } else {
                button.setTitle(String.fontAwesomeIconWithName(.Play), forState: .Normal)
            }
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playPauseToggle(sender: UIButton) {
        let isPlaying = SoundManager.sharedInstance.avPlayer.rate != 0
        if isPlaying {
            SoundManager.sharedInstance.pausePlaying()
        } else {
            SoundManager.sharedInstance.startPlaying()
        }
    }
    
    @IBAction func progressSliderEndTouches(sender: AnyObject) {
        if let duration = SoundManager.sharedInstance.avPlayer.currentItem?.duration {
            let timeInSeconds = CMTimeGetSeconds(duration)
            let finalTimeInSeconds = (Double( self.progressSlider.value ) * timeInSeconds)
            let finalTime = CMTime(seconds: finalTimeInSeconds, preferredTimescale: duration.timescale)
            SoundManager.sharedInstance.avPlayer.seekToTime(finalTime) { (completed) in
                self.progressSliderDragging = false
            }
        }
    }
    
    @IBAction func progressSliderStartTouches(sender: AnyObject) {
        progressSliderDragging = true
    }

    @IBAction func skipForward(sender: AnyObject) {
        SoundManager.sharedInstance.skipForward(30)
    }
    
    @IBAction func skipBackward(sender: AnyObject) {
        SoundManager.sharedInstance.skipBackward(30)
    }
    
    @IBAction func toggleRate(sender: AnyObject) {
        audioRate.next().save()
        SoundManager.sharedInstance.setRate(audioRate.rawValue)
        rateButton.setTitle(audioRate.title, forState: .Normal)
    }
}

extension AudioPlayerViewController: UIViewControllerRestoration {
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        return AudioPlayerViewController(coder: coder)
    }
}
