//
//  ArticleViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 18/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import AlamofireImage
import WebKit
import CoreData
import SafariServices

protocol HtmlArticle : class, ObjectURIRepresentable {
    var articleTitle: String { get }
    var articleURL: String { get }
    var articleBody: String { get }
    var articleAuthor: String? { get }
    var articleDate: Date? { get }
    var articleAuthorImage: String? { get }
    var articleCompleted: Bool { get set }
    var managedObjectContext: NSManagedObjectContext? { get }
    var showAuthor: Bool { get }
    var showTitle: Bool { get }
}

extension Article: HtmlArticle {
    var articleTitle: String {
        return self.title ?? ""
    }
    
    var articleURL: String {
        return self.url ?? ""
    }
    
    var articleBody: String {
        return self.body ?? ""
    }
    
    var articleAuthor: String? {
        if let name = self.authorName, name.count > 0 {
            return name
        }
        return nil
    }
    
    var articleDate: Date? {
        return self.postedDate
    }
    
    var articleAuthorImage: String? {
        if let name = self.authorThumbnailSource, name.count > 0 {
            return name
        }
        return nil
    }
    
    var articleCompleted: Bool {
        get {
            return completed
        }
        set {
            completed = newValue
        }
    }
    
    var showTitle: Bool {
        return true
    }
    
    var showAuthor: Bool {
        return true
    }
}

extension Answer: HtmlArticle {
    var articleTitle: String {
        return self.title ?? ""
    }
    
    var articleURL: String {
        return self.url ?? ""
    }
    
    var articleBody: String {
        return self.body ?? ""
    }
    
    var articleAuthor: String? {
        if let name = self.authorName, name.count > 0 {
            return name
        }
        return nil
    }
    
    var articleDate: Date? {
        return self.postedDate
    }
    
    var articleAuthorImage: String? {
        return nil
    }
    
    var articleCompleted: Bool {
        get {
            return completed
        }
        set {
            completed = newValue
        }
    }
    
    var showTitle: Bool {
        return false
    }
    
    var showAuthor: Bool {
        return false
    }
}

class ArticleViewController: UIViewController, WKNavigationDelegate {

    private let htmlBody = try! String(contentsOf: Bundle.main.url(forResource: "ArticleBody", withExtension: "html")!, encoding: .utf8)
    
    private let activity = NSUserActivity(activityType: "org.versebyverseministry.www")
    
    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    var article: HtmlArticle! {
        didSet {
            self.navigationItem.title = article.articleTitle
            loadArticle(article)
            
            if let url = URL(string: article.articleURL) {
                activity.title = article.articleTitle
                activity.webpageURL = url
                activity.becomeCurrent()
            }
        }
    }
    var dateFormatter = DateFormatter()
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(article.objectURIRepresentation, forKey: "articleIdentifier")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let identifier = coder.decodeObject(forKey: "articleIdentifier") as? URL else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        let object = context?.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: identifier)
        self.article = (object as! HtmlArticle)
        super.decodeRestorableState(with: coder)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activity.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        dateFormatter.dateStyle = .medium
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
        
        
    }
    
    @objc func shareAction(_ button: Any) {
        guard let url = URL(string: article.articleURL) else { return }
        
        let actionSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(actionSheet, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if article.articleCompleted == false {
            article.articleCompleted = true
            do {
                try article.managedObjectContext?.save()
            } catch {
                
            }
        }
    }
    
    private func loadArticle(_ article: HtmlArticle) {
        let body = article.articleBody
        var htmlContent = htmlBody.replacingAll(matching: "ARTICLE_CONTENT", with: body)
        
        let date = article.articleDate
        let dateString: String
        if let date = date {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = ""
        }
        htmlContent.replaceAll(matching: "ARTICLE_DATE", with: dateString)
        htmlContent.replaceAll(matching: "AUTHOR_NAME", with: article.showAuthor ? article.articleAuthor ?? "" : "")
        htmlContent.replaceAll(matching: "ARTICLE_TITLE", with: article.showTitle ? article.articleTitle : "")
        
        let imageTag : String
        if article.showAuthor, let imageURL = article.articleAuthorImage {
            imageTag = "<img id=\"author_image\" src=\"\(imageURL)\" align=\"left\" alt=\"\(article.articleAuthor ?? "")\" />"
        } else {
            imageTag = ""
        }
        
        htmlContent.replaceAll(matching: "AUTHOR_IMAGE", with: imageTag)
        webView.loadHTMLString(htmlContent, baseURL: URL(string: "https://versebyverseministry.org/")!)
        
        webView.navigationDelegate = self
    }

    override func viewDidLayoutSubviews() {
        if #available(iOS 11, *) {
            
        } else {
            //let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        }
       
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
