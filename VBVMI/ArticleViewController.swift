//
//  ArticleViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 18/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import AlamofireImage


class ArticleViewController: UITableViewController {

    private let activity = NSUserActivity(activityType: "org.versebyverseministry.www")
    
    var article: Article! {
        didSet {
            self.navigationItem.title = article.title
            if let body = article.body {
                bodyPieces = body.components(separatedBy: "\r\n\r\n")
                if bodyPieces.count > 1 {
                    let str = "\(bodyPieces[0])\r\n\r\n\(bodyPieces[1])"
                    bodyPieces.remove(at: 0)
                    bodyPieces.remove(at: 0)
                    bodyPieces.insert(str, at: 0)
                }
            }
            
            if let urlString = article.url, let url = URL(string: urlString) {
                activity.title = article.title
                activity.webpageURL = url
                activity.becomeCurrent()
            }
        }
    }
    var dateFormatter = DateFormatter()
    
    var bodyPieces = [String]()
    
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

        dateFormatter.dateStyle = .medium
        
        tableView.register(UINib(nibName: Cell.NibName.ArticleHeader, bundle: nil), forCellReuseIdentifier: Cell.Identifier.ArticleHeader)
        tableView.register(UINib(nibName: Cell.NibName.ArticleBody, bundle: nil), forCellReuseIdentifier: Cell.Identifier.ArticleBody)
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    func shareAction(_ button: Any) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return bodyPieces.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return 100
        case 1:
            return 150
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.ArticleHeader, for: indexPath) as! ArticleHeaderTableViewCell
                
                if let title = article.title {
                    cell.titleLabel.text = title
                    cell.titleLabel.isHidden = false
                } else {
                    cell.titleLabel.isHidden = true
                }
                
                if let author = article.authorName {
                    cell.authorLabel.text = author
                    cell.authorLabel.isHidden = false
                } else {
                    cell.authorLabel.isHidden = true
                }
                
                if let date = article.postedDate {
                    cell.postedDateLabel.text = dateFormatter.string(from: date as Date)
                    cell.postedDateLabel.isHidden = false
                } else {
                    cell.postedDateLabel.isHidden = true
                }
                
                return cell
            default:
                fatalError()
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.ArticleBody, for: indexPath) as! ArticleBodyTableViewCell
            
            cell.bodyTextView.text = bodyPieces[(indexPath as NSIndexPath).row]
            
            if (indexPath as NSIndexPath).row == 0 {
                cell.hasImage = true
                if let urlString = article.authorThumbnailSource, let url = URL(string: urlString) {
                    cell.authorImageView?.af_setImage(withURL: url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.25), runImageTransitionIfCached: false)
                }
            } else {
                cell.hasImage = false
                cell.authorImageView.image = nil
            }
            return cell
        default:
            fatalError()
        }
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {

            } else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.ArticleBody, for: indexPath) as! ArticleBodyTableViewCell
                
                cell.bodyTextView.text = article.body
                
                if let urlString = article.authorThumbnailSource, let url = URL(string: urlString) {
                    cell.authorImageView?.af_setImage(withURL: url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.25), runImageTransitionIfCached: false)
                }
                
                return cell
            }
        }
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
}
