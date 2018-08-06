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


class ArticleViewController: UIViewController {

    private let htmlBody = try! String(contentsOf: Bundle.main.url(forResource: "ArticleBody", withExtension: "html")!, encoding: .utf8)
    
    private let activity = NSUserActivity(activityType: "org.versebyverseministry.www")
    
    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    var article: Article! {
        didSet {
            self.navigationItem.title = article.title
            loadArticle(article)
            
            if let urlString = article.url, let url = URL(string: urlString) {
                activity.title = article.title
                activity.webpageURL = url
                activity.becomeCurrent()
            }
        }
    }
    var dateFormatter = DateFormatter()
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(article.identifier, forKey: "articleIdentifier")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let identifier = coder.decodeObject(forKey: "articleIdentifier") as? String else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        guard let article: Article = Article.findFirstWithPredicate(NSPredicate(format: "%K == %@", ArticleAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.article = article
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
        guard let urlString = article?.url, let url = URL(string: urlString) else { return }
        
        let actionSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(actionSheet, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if article.completed == false {
            article.completed = true
            do {
                try article.managedObjectContext?.save()
            } catch {
                
            }
        }
    }
    
    private func loadArticle(_ article: Article) {
        let body = article.body ?? ""
        var htmlContent = htmlBody.replacingAll(matching: "ARTICLE_CONTENT", with: body)
        
        let date = article.postedDate
        let dateString: String
        if let date = date {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = ""
        }
        htmlContent.replaceAll(matching: "ARTICLE_DATE", with: dateString)
        htmlContent.replaceAll(matching: "AUTHOR_NAME", with: article.authorName ?? "")
        htmlContent.replaceAll(matching: "ARTICLE_TITLE", with: article.title ?? "")
        
        let imageTag : String
        if let imageURL = article.authorThumbnailSource {
            imageTag = "<img id=\"author_image\" src=\"\(imageURL)\" align=\"left\" alt=\"\(article.authorName ?? "")\" />"
        } else {
            imageTag = ""
        }
        
        htmlContent.replaceAll(matching: "AUTHOR_IMAGE", with: imageTag)
        webView.loadHTMLString(htmlContent, baseURL: URL(string: "https://versebyverseministry.org/")!)
    }

    override func viewDidLayoutSubviews() {
        if #available(iOS 11, *) {
            
        } else {
            //let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        }
       
    }
    
}
