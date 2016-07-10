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

    var article: Article! {
        didSet {
            self.navigationItem.title = article.title
            if let body = article.body {
                bodyPieces = body.componentsSeparatedByString("\r\n\r\n")
                if bodyPieces.count > 1 {
                    let str = "\(bodyPieces[0])\r\n\r\n\(bodyPieces[1])"
                    bodyPieces.removeAtIndex(0)
                    bodyPieces.removeAtIndex(0)
                    bodyPieces.insert(str, atIndex: 0)
                }
            }
        }
    }
    var dateFormatter = NSDateFormatter()
    
    var bodyPieces = [String]()
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(article.identifier, forKey: "articleIdentifier")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        guard let identifier = coder.decodeObjectForKey("articleIdentifier") as? String else {
            fatalError()
        }
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        guard let article: Article = Article.findFirstWithPredicate(NSPredicate(format: "%K == %@", ArticleAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.article = article
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .MediumStyle
        
        tableView.registerNib(UINib(nibName: Cell.NibName.ArticleHeader, bundle: nil), forCellReuseIdentifier: Cell.Identifier.ArticleHeader)
        tableView.registerNib(UINib(nibName: Cell.NibName.ArticleBody, bundle: nil), forCellReuseIdentifier: Cell.Identifier.ArticleBody)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(animated: Bool) {
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return bodyPieces.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        case 1:
            return 150
        default:
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Identifier.ArticleHeader, forIndexPath: indexPath) as! ArticleHeaderTableViewCell
                
                if let title = article.title {
                    cell.titleLabel.text = title
                    cell.titleLabel.hidden = false
                } else {
                    cell.titleLabel.hidden = true
                }
                
                if let author = article.authorName {
                    cell.authorLabel.text = author
                    cell.authorLabel.hidden = false
                } else {
                    cell.authorLabel.hidden = true
                }
                
                if let date = article.postedDate {
                    cell.postedDateLabel.text = dateFormatter.stringFromDate(date)
                    cell.postedDateLabel.hidden = false
                } else {
                    cell.postedDateLabel.hidden = true
                }
                
                return cell
            default:
                fatalError()
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Identifier.ArticleBody, forIndexPath: indexPath) as! ArticleBodyTableViewCell
            
            cell.bodyTextView.text = bodyPieces[indexPath.row]
            
            if indexPath.row == 0 {
                cell.hasImage = true
                if let urlString = article.authorThumbnailSource, url = NSURL(string: urlString) {
                    cell.authorImageView?.af_setImageWithURL(url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.25), runImageTransitionIfCached: false)
                }
            } else {
                cell.hasImage = false
                cell.authorImageView.image = nil
            }
            return cell
        default:
            fatalError()
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {

            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Identifier.ArticleBody, forIndexPath: indexPath) as! ArticleBodyTableViewCell
                
                cell.bodyTextView.text = article.body
                
                if let urlString = article.authorThumbnailSource, url = NSURL(string: urlString) {
                    cell.authorImageView?.af_setImageWithURL(url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.25), runImageTransitionIfCached: false)
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
