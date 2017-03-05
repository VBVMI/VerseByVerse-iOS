//
//  AnswerViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 19/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit


class AnswerViewController: UITableViewController {

    var answer: Answer! {
        didSet {
            self.navigationItem.title = answer.title
            
            if let body = answer.body {
                bodyPieces = body.components(separatedBy: "\r\n\r\n")
                if bodyPieces.count > 1 {
                    let str = "\(bodyPieces[0])\r\n\r\n\(bodyPieces[1])"
                    bodyPieces.remove(at: 0)
                    bodyPieces.remove(at: 0)
                    bodyPieces.insert(str, at: 0)
                }
            }
        }
    }
    
    var dateFormatter = DateFormatter()
    var bodyPieces = [String]()
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(answer.identifier, forKey: "answerIdentifier")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let identifier = coder.decodeObject(forKey: "answerIdentifier") as? String else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        guard let answer: Answer = Answer.findFirstWithPredicate(NSPredicate(format: "%K == %@", AnswerAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.answer = answer
        super.decodeRestorableState(with: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        
        tableView.register(UINib(nibName: Cell.NibName.AnswerHeader, bundle: nil), forCellReuseIdentifier: Cell.Identifier.AnswerHeader)
        tableView.register(UINib(nibName: Cell.NibName.AnswerBody, bundle: nil), forCellReuseIdentifier: Cell.Identifier.AnswerBody)
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    func shareAction(_ button: Any) {
        guard let urlString = answer?.url, let url = URL(string: urlString) else { return }
        
        let actionSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(actionSheet, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if answer.completed == false {
            answer.completed = true
            do {
                try answer.managedObjectContext?.save()
            } catch {
                
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.AnswerHeader, for: indexPath) as! AnswerHeaderTableViewCell
                
                if let title = answer.title {
                    cell.titleLabel.text = title
                    cell.titleLabel.isHidden = false
                } else {
                    cell.titleLabel.isHidden = true
                }
                
                if let author = answer.authorName {
                    cell.authorLabel.text = author
                    cell.authorLabel.isHidden = false
                } else {
                    cell.authorLabel.isHidden = true
                }
                
                if let date = answer.postedDate {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.Identifier.AnswerBody, for: indexPath) as! AnswerBodyTableViewCell
            
            cell.bodyTextView.text = bodyPieces[(indexPath as NSIndexPath).row]
            
            return cell
        default:
            fatalError()
        }
        fatalError()
    }

    override func viewDidLayoutSubviews() {
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
