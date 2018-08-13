//
//  QuestionsViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class AnswersViewController: UITableViewController {

    fileprivate var fetchedResultsController: NSFetchedResultsController<Answer>!
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var aboutActionsController: AboutActionsController!
    var topic: Topic? {
        didSet {
            if let topic = topic {
                let articleIdentifiers = topic.answers.map({ (answer) -> String in
                    return answer.identifier
                })
                defaultPredicate = NSPredicate(format: "%K IN %@", AnswerAttributes.identifier.rawValue ,articleIdentifiers)
            }
        }
    }
    fileprivate var defaultPredicate: NSPredicate?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        dateFormatter.dateStyle = .short
        tableView.rowHeight = UITableViewAutomaticDimension
        self.definesPresentationContext = true
        
        self.tableView.register(UINib(nibName: Cell.NibName.Article, bundle: nil), forCellReuseIdentifier: Cell.Identifier.Article)
        
        let fetchRequest = NSFetchRequest<Answer>(entityName: Answer.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Answer.entity(managedObjectContext: context)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: AnswerAttributes.postedDate.rawValue, ascending: false)]
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchRequest.predicate = defaultPredicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async { () -> Void in
                self.tableView.reloadData()
            }
        } catch let error {
            logger.error("Error fetching: \(error)")
        }
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem
        
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        if topic == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
            self.refreshControl = refreshControl
        }
        
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        APIDataManager.allTheAnswers { 
            sender.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            
        } else {
            if self.parent == nil {
                let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
                tableView.contentInset = insets
                tableView.scrollIndicatorInsets = insets
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.Article, for: indexPath) as! ArticleTableViewCell
        
        let answer = fetchedResultsController.object(at: indexPath)
        let topics = answer.topics
        if topics.count > 0 {
            cell.topicLayoutView.isHidden = false
            let filteredTopics: Set<Topic> = topics.filter( {$0.name?.count > 0 })
            let sortedTopics = filteredTopics.sorted(by: { (left, right) -> Bool in
                return left.name!.localizedCompare(right.name!) == ComparisonResult.orderedAscending
            })
            cell.topicLayoutView.topics = sortedTopics
            
            cell.topicLayoutView.topicSelectedBlock = { [weak self] (topic) in
                guard let this = self else { return }
                let topicVC = TopicViewController(nibName: "TopicViewController", bundle: nil)
                topicVC.topic = topic
                topicVC.selectedSegment = .answers
                this.navigationController?.pushViewController(topicVC, animated: true)
            }
            
        } else {
            cell.topicLayoutView.isHidden = true
        }

        cell.titleLabel.textColor = answer.completed ? StyleKit.darkGrey : StyleKit.orange
        cell.titleLabel.text = answer.title
        cell.authorLabel.text = answer.authorName
        if let date = answer.postedDate {
            let dateText = dateFormatter.string(from: date)
            
            cell.dateLabel.text = dateText
            cell.dateLabel.isHidden = false
        } else {
            cell.dateLabel.isHidden = true
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        if sections.count <= section {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let answer = self.fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: "showAnswer", sender: answer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let answer = sender as? Answer {
            if let destinationViewController = segue.destination as? ArticleViewController {
                destinationViewController.article = answer
            }
        }
    }

}

extension AnswersViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.debug("Controller didChangeContent")
        self.tableView.reloadData()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.debug("Will change content")
    }
}

extension AnswersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let fetchRequest = fetchedResultsController.fetchRequest
        if let text = searchController.searchBar.text , text.count > 0 {
            var predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", AnswerAttributes.title.rawValue, text, AnswerAttributes.body.rawValue, text)
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
            logger.error("Answers Search: \(error)")
        }
        
    }
}

extension AnswersViewController: UISearchBarDelegate {
    
}
