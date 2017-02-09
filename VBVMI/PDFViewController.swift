//
//  PDFViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 20/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPDF()
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    func share() {
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
            webView.delegate = self
            webView.loadRequest(urlRequest)
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
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
//    override var prefersStatusBarHidden : Bool {
//        return self.navigationController?.isNavigationBarHidden ?? false
//    }
//    
    override func viewDidLayoutSubviews() {
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
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

extension PDFViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.scrollView.setContentOffset(CGPoint(x:0, y: -self.topLayoutGuide.length), animated: false)
    }
}
