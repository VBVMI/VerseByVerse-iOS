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
    
    var urlToLoad: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPDF()
    }
    
    private func loadPDF() {
        if let url = urlToLoad {
            let urlRequest = NSURLRequest(URL: url)
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.navigationController?.navigationBarHidden ?? false
    }
    
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
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.scrollView.setContentOffset(CGPoint(x:0, y: -self.topLayoutGuide.length), animated: false)
    }
}
