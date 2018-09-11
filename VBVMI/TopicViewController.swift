//
//  TopicViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 27/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController {

    let segmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    
    var topic: Topic!
    var selectedSegment: TypeSelection = .studies
    
    enum TypeSelection: Int {
        case studies = 0
        case articles = 1
        case answers = 2
        
        var title: String {
            return "\(self)"
        }
        
        func viewController(_ topic: Topic) -> UIViewController {
            switch self {
            case .articles:
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "Articles") as! ArticlesViewController
                viewController.topic = topic
                return viewController
            case .answers:
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "Answers") as! AnswersViewController
                viewController.topic = topic
                return viewController
            default:
                return UIViewController()
            }
        }
    }
    
    var segmentToIndexMap = [TypeSelection : Int]()
    var indexToSegmentMap = [Int: TypeSelection]()
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(topic.identifier, forKey: "topicIdentifier")
        coder.encode(selectedSegment.rawValue, forKey: "selectedSegment")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let identifier = coder.decodeObject(forKey: "topicIdentifier") as? String else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        guard let topic: Topic = Topic.findFirstWithPredicate(NSPredicate(format: "%K == %@", TopicAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.topic = topic
        self.selectedSegment = TypeSelection(rawValue: coder.decodeInteger(forKey: "selectedSegment"))!
        super.decodeRestorableState(with: coder)
        
        configureForTopic()
        configureSegmentedControl()
    }
    
    fileprivate func configureForTopic() {
        var currentIndex = 0
        //        if topic.studies.count > 0 || topic.lessons.count > 0 {
        //            segmentedControl.insertSegmentWithTitle(TypeSelection.Studies.title, atIndex: currentIndex, animated: false)
        //            segmentToIndexMap[.Studies] = currentIndex
        //            indexToSegmentMap[currentIndex] = .Studies
        //            currentIndex += 1
        //        }
        if topic.answers.count > 0 {
            segmentedControl.insertSegment(withTitle: TypeSelection.answers.title, at: currentIndex, animated: false)
            segmentToIndexMap[.answers] = currentIndex
            indexToSegmentMap[currentIndex] = .answers
            currentIndex += 1
        }
        if topic.articles.count > 0 {
            segmentedControl.insertSegment(withTitle: TypeSelection.articles.title, at: currentIndex, animated: false)
            segmentToIndexMap[.articles] = currentIndex
            indexToSegmentMap[currentIndex] = .articles
            currentIndex += 1
        }
        
        self.navigationItem.titleView = segmentedControl
//        self.navigationItem.prompt = topic.name
    }
    
    fileprivate func configureSegmentedControl() {
        if let index = segmentToIndexMap[selectedSegment] {
            segmentedControl.selectedSegmentIndex = index
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        segmentedControl.addTarget(self, action: #selector(TopicViewController.segmentedControlChanged(_:)), for: .valueChanged)
        self.segmentedControlChanged(segmentedControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restorationIdentifier = "TopicViewController"
        restorationClass = TopicViewController.self
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        if let _ = topic {
            configureForTopic()
            configureSegmentedControl()
        }
    }

    fileprivate var currentViewController : UIViewController?
    fileprivate func configureSubviewController(_ viewController: UIViewController) {
        if let current = currentViewController {
            current.willMove(toParentViewController: nil)
            current.removeFromParentViewController()
            current.view.removeFromSuperview()
        }
        
        viewController.willMove(toParentViewController: self)
        self.addChildViewController(viewController)
//        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        
        viewController.view.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        viewController.didMove(toParentViewController: self)
        
        currentViewController = viewController
        
        if #available(iOS 11.0, *) {
            
        } else {
            if let tableViewController = currentViewController as? UITableViewController {
                let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
                tableViewController.tableView.contentInset = insets
                tableViewController.tableView.scrollIndicatorInsets = insets
                tableViewController.tableView.contentOffset = CGPoint(x: 0, y: -topLayoutGuide.length)
            }
        }
//        viewController.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            
        } else {
            if let tableViewController = currentViewController as? UITableViewController {
                let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
                tableViewController.tableView.contentInset = insets
                tableViewController.tableView.scrollIndicatorInsets = insets
                tableViewController.tableView.contentOffset = CGPoint(x: 0, y: -topLayoutGuide.length)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
//        logger.info("🍕value: \(sender.selectedSegmentIndex)")
        self.selectedSegment = indexToSegmentMap[sender.selectedSegmentIndex]!
        let viewController = self.selectedSegment.viewController(topic)
        configureSubviewController(viewController)
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

extension TopicViewController : UIViewControllerRestoration {
    static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        let vc = TopicViewController(nibName: "TopicViewController", bundle: nil)
        return vc
    }
}
