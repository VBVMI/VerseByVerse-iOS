//
//  PDFViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 20/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import WebKit

class PDFViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    private var attachedToNavController = false
    private var showStatusBar = true
    private var curFramePosition: Double = 0
    
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPDF()
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func share() {
        guard let urlToLoad = urlToLoad else {
            return
        }
        
        let items = [urlToLoad]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        present(activityController, animated: true, completion: nil)
    }
    
    fileprivate func loadPDF() {
        if let url = urlToLoad {
            let urlRequest = URLRequest(url: url)
            webView.navigationDelegate = self
            webView.load(urlRequest)
            if self.title == nil {
                self.title = url.lastPathComponent
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.hidesBarsOnTap = true
        if #available(iOS 11.0, *) {
            
        } else {
            
            self.navigationController?.hidesBarsOnSwipe = true
            if !attachedToNavController {
                self.navigationController?.barHideOnSwipeGestureRecognizer.addTarget(self, action: #selector(didSwipe(_:)))
                attachedToNavController = true
            }
        }
        
        Analytics.setScreenName("LessonPDF-\(urlToLoad?.lastPathComponent ?? "")", screenClass: "PDFView")
    }
    
    @objc func didSwipe(_ swipe: UIPanGestureRecognizer) {
        if #available(iOS 11.0, *) {
            return
        }
        // Visible to hidden
        if curFramePosition == 0 && self.navigationController?.navigationBar.frame.origin.y == -44 {
            curFramePosition = -44
            showStatusBar = false
            setNeedsStatusBarAppearanceUpdate()
        }
            // Hidden to visible
        else if curFramePosition == -44 && self.navigationController?.navigationBar.frame.origin.y == 0 {
            curFramePosition = 0
            showStatusBar = true
            setNeedsStatusBarAppearanceUpdate()
        }
        
    }
    
    
    override var prefersStatusBarHidden : Bool {
        if #available(iOS 11.0, *) {
            return false
        }
        return !showStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
//
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            return
        } else {
            let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            webView.scrollView.contentInset = insets
            webView.scrollView.scrollIndicatorInsets = insets
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension PDFViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if #available(iOS 11.0, *) {
            return
        } else {
            webView.scrollView.setContentOffset(CGPoint(x:0, y: -self.topLayoutGuide.length), animated: false)
        }
    }
    
}
