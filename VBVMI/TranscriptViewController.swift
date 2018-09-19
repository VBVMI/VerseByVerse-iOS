//
//  TranscriptViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 28/07/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import FirebaseAnalytics

class TranscriptViewController: UIViewController, HidableStatusbarController, WKNavigationDelegate {

    var shouldHideStatusBar: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    private static let customRestorationIdentifier = "org.versebyverseministry.TranscriptViewController"
    
    private enum CodableKeys : String {
        case lesson
        case study
        case transcriptURL
    }
    
    var lesson: Lesson
    var study: Study
    
    var contentSizeNotificationToken : NSObjectProtocol?
    
    let textView = UITextView(frame: .zero)
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        
        return webView
    }()
    
    lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        return button
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.done, target: self, action: #selector(closeTapped))
        return button
    }()
    let queue = DispatchQueue(label: "TranscriptLoader")
    
    init(study: Study, lesson: Lesson) {
        self.study = study
        self.lesson = lesson
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(lesson.objectURIRepresentation, forKey: CodableKeys.lesson.rawValue)
        coder.encode(study.objectURIRepresentation, forKey: CodableKeys.study.rawValue)
        
        super.encodeRestorableState(with: coder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        
        guard let studyURI = aDecoder.decodeObject(forKey: CodableKeys.study.rawValue) as? URL,
            let studyID = context?.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: studyURI),
            let study = (try? context?.existingObject(with: studyID)) as? Study else {
                return nil
        }
        self.study = study
        
        guard let lessonURI = aDecoder.decodeObject(forKey: CodableKeys.lesson.rawValue) as? URL,
            let lessonID = context?.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: lessonURI),
            let lesson = (try? context?.existingObject(with: lessonID)) as? Lesson else {
                return nil
        }
        self.lesson = lesson
        
        super.init(coder: aDecoder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restorationIdentifier = TranscriptViewController.customRestorationIdentifier
        self.restorationClass = TranscriptViewController.self
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.title = lesson.title
        navigationItem.rightBarButtonItem = shareButton
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = true
        
        contentSizeNotificationToken = NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: nil) { [weak self] (notification) in
            self?.loadHTML()
        }
        
        loadHTML()
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        Analytics.setScreenName("\(study.title)-\(lesson.lessonNumber ?? "")", screenClass: "TranscriptViewController")
    }
    
    private func loadHTML() {
        guard let urlString = ResourceManager.LessonType.transcriptHTML.urlString(lesson), let transcriptURL = URL(string: urlString) else { return }

        queue.async {
            let transcriptHTML = (try? String(contentsOf: transcriptURL, encoding: .utf8)) ?? ""
            
            DispatchQueue.main.async {
                self.webView.loadHTMLString(transcriptHTML, baseURL: URL(string: "https://versebyverseministry.org")!)
                self.webView.navigationDelegate = self
            }
        }
    }
    
    deinit {
        if let token = contentSizeNotificationToken {
            NotificationCenter.default.removeObserver(token)
        }
        contentSizeNotificationToken = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: view.layoutMargins.left, bottom: bottomLayoutGuide.length, right: view.layoutMargins.right)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    @objc private func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func share() {
        guard let urlString = lesson.url, let urlToLoad = URL(string: urlString) else {
            return
        }
        
        let items = [urlToLoad]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityController.popoverPresentationController?.barButtonItem = shareButton
        
        present(activityController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString == "https://versebyverseministry.org/" {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        
        if let url = navigationAction.request.url {
            let controller = SFSafariViewController(url: url)
            present(controller, animated: true, completion: nil)
        }
        
        decisionHandler(WKNavigationActionPolicy.cancel)
    }
}

extension TranscriptViewController: UIViewControllerRestoration {
    static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        return TranscriptViewController(coder: coder)
    }
}
