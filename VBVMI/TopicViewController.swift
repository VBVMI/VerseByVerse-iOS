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
    var selectedSegment: TypeSelection = .Studies
    
    enum TypeSelection: Int {
        case Studies = 0
        case Articles = 1
        case Answers = 2
        
        var title: String {
            return "\(self)"
        }
        
        func viewController(topic: Topic) -> UIViewController {
            switch self {
            case .Articles:
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("Articles") as! ArticlesViewController
                viewController.topic = topic
                return viewController
            case .Answers:
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("Answers") as! AnswersViewController
                viewController.topic = topic
                return viewController
            default:
                return UIViewController()
            }
        }
    }
    
    var segmentToIndexMap = [TypeSelection : Int]()
    var indexToSegmentMap = [Int: TypeSelection]()
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(topic.identifier, forKey: "topicIdentifier")
        coder.encodeInteger(selectedSegment.rawValue, forKey: "selectedSegment")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        guard let identifier = coder.decodeObjectForKey("topicIdentifier") as? String else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        guard let topic: Topic = Topic.findFirstWithPredicate(NSPredicate(format: "%K == %@", TopicAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.topic = topic
        self.selectedSegment = TypeSelection(rawValue: coder.decodeIntegerForKey("selectedSegment"))!
        super.decodeRestorableStateWithCoder(coder)
        
        configureForTopic()
        configureSegmentedControl()
    }
    
    private func configureForTopic() {
        var currentIndex = 0
        //        if topic.studies.count > 0 || topic.lessons.count > 0 {
        //            segmentedControl.insertSegmentWithTitle(TypeSelection.Studies.title, atIndex: currentIndex, animated: false)
        //            segmentToIndexMap[.Studies] = currentIndex
        //            indexToSegmentMap[currentIndex] = .Studies
        //            currentIndex += 1
        //        }
        if topic.articles.count > 0 {
            segmentedControl.insertSegmentWithTitle(TypeSelection.Articles.title, atIndex: currentIndex, animated: false)
            segmentToIndexMap[.Articles] = currentIndex
            indexToSegmentMap[currentIndex] = .Articles
            currentIndex += 1
        }
        if topic.answers.count > 0 {
            segmentedControl.insertSegmentWithTitle(TypeSelection.Answers.title, atIndex: currentIndex, animated: false)
            segmentToIndexMap[.Answers] = currentIndex
            indexToSegmentMap[currentIndex] = .Answers
            currentIndex += 1
        }
        
        self.navigationItem.titleView = segmentedControl
//        self.navigationItem.prompt = topic.name
    }
    
    private func configureSegmentedControl() {
        if let index = segmentToIndexMap[selectedSegment] {
            segmentedControl.selectedSegmentIndex = index
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        segmentedControl.addTarget(self, action: #selector(TopicViewController.segmentedControlChanged(_:)), forControlEvents: .ValueChanged)
        self.segmentedControlChanged(segmentedControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restorationIdentifier = "TopicViewController"
        restorationClass = TopicViewController.self
        
        if let _ = topic {
            configureForTopic()
            configureSegmentedControl()
        }
    }

    private var currentViewController : UIViewController?
    private func configureSubviewController(viewController: UIViewController) {
        if let current = currentViewController {
            current.willMoveToParentViewController(nil)
            current.removeFromParentViewController()
            current.view.removeFromSuperview()
        }
        
        viewController.willMoveToParentViewController(self)
        self.addChildViewController(viewController)
//        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        
        viewController.view.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        viewController.didMoveToParentViewController(self)
        
        currentViewController = viewController
        
        if let tableViewController = currentViewController as? UITableViewController {
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            tableViewController.tableView.contentInset = insets
            tableViewController.tableView.scrollIndicatorInsets = insets
            tableViewController.tableView.contentOffset = CGPointMake(0, -topLayoutGuide.length)
        }
//        viewController.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        if let tableViewController = currentViewController as? UITableViewController {
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            tableViewController.tableView.contentInset = insets
            tableViewController.tableView.scrollIndicatorInsets = insets
            tableViewController.tableView.contentOffset = CGPointMake(0, -topLayoutGuide.length)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segmentedControlChanged(sender: UISegmentedControl) {
//        print("value: \(sender.selectedSegmentIndex)")
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
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        let vc = TopicViewController(nibName: "TopicViewController", bundle: nil)
        return vc
    }
}