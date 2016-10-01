//
//  ArticlesViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData


class ArticlesViewController: UITableViewController {

    var fetchedResultsController: NSFetchedResultsController!
    let dateFormatter = NSDateFormatter()
    let searchController = UISearchController(searchResultsController: nil)
    var aboutActionsController: AboutActionsController!
    var topic: Topic? {
        didSet {
            if let topic = topic {
                let articleIdentifiers = topic.articles.map({ (article) -> String in
                    return article.identifier
                })
                defaultPredicate = NSPredicate(format: "%K IN %@", ArticleAttributes.identifier.rawValue ,articleIdentifiers)
            }
        }
    }
    private var defaultPredicate: NSPredicate?
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        dateFormatter.dateStyle = .ShortStyle
        
        
        self.definesPresentationContext = true
        
        self.tableView.registerNib(UINib(nibName: Cell.NibName.Article, bundle: nil), forCellReuseIdentifier: Cell.Identifier.Article)

        let fetchRequest = NSFetchRequest(entityName: Article.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        fetchRequest.entity = Article.entity(context)
        let identifierSort = NSSortDescriptor(key: ArticleAttributes.identifier.rawValue, ascending: false, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ArticleAttributes.postedDate.rawValue, ascending: false), identifierSort]
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchRequest.predicate = defaultPredicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        } catch let error {
            log.error("Error fetching: \(error)")
        }
        
        self.tableView.tableHeaderView = searchController.searchBar
        // Do any additional setup after loading the view
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        if topic == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
            self.refreshControl = refreshControl
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        APIDataManager.allTheArticles {
            sender.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if self.parentViewController == nil {
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Identifier.Article, forIndexPath: indexPath) as! ArticleTableViewCell
        
        if let article = fetchedResultsController.objectAtIndexPath(indexPath) as? Article {
            cell.titleLabel.text = article.title
            cell.titleLabel.textColor = article.completed ? StyleKit.darkGrey : StyleKit.orange
            cell.authorLabel.text = article.authorName
            let topics = article.topics
            if topics.count > 0 {
                
                cell.topicLayoutView.hidden = false
                
                let sortedTopics = topics.filter( {$0.name?.characters.count > 0 }).sort({ (left, right) -> Bool in
                    return left.name!.localizedCompare(right.name!) == NSComparisonResult.OrderedAscending
                })
                cell.topicLayoutView.topics = sortedTopics
                
                cell.topicLayoutView.topicSelectedBlock = { [weak self] (topic) in
                    guard let this = self else { return }
                    let topicVC = TopicViewController(nibName: "TopicViewController", bundle: nil)
                    topicVC.topic = topic
                    topicVC.selectedSegment = .Articles
                    this.navigationController?.pushViewController(topicVC, animated: true)
                }
                
            } else {
                cell.topicLayoutView.hidden = true
            }
            
            if let date = article.postedDate {
                let dateText = dateFormatter.stringFromDate(date)
                
                cell.dateLabel.text = dateText
                cell.dateLabel.hidden = false
            } else {
                cell.dateLabel.hidden = true
            }
        }
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        if sections.count <= section {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 59
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let article = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Article {
            self.performSegueWithIdentifier("showArticle", sender: article)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let article = sender as? Article {
            if let destinationViewController = segue.destinationViewController as? ArticleViewController {
                destinationViewController.article = article
            }
        }
    }
}

extension ArticlesViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        log.debug("Controller didChangeContent")
        self.tableView.reloadData()
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        log.debug("Will change content")
    }
}

extension ArticlesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let fetchRequest = fetchedResultsController.fetchRequest
        if let text = searchController.searchBar.text where text.characters.count > 0 {
            var predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", ArticleAttributes.title.rawValue, text, ArticleAttributes.body.rawValue, text)
            if let defaultPredicate = defaultPredicate {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
            }
            fetchRequest.predicate = predicate
        } else {
            fetchRequest.predicate = defaultPredicate
        }
        
        do {
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch let error {
            log.error("Articles Search: \(error)")
        }
        
    }
}

extension ArticlesViewController: UISearchBarDelegate {
    
}
