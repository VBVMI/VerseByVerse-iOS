//
//  AboutActionsController.swift
//  VBVMI
//
//  Created by Thomas Carey on 23/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import SafariServices

class AboutActionsController: NSObject {

    private static let buttonFont = UIFont.fontAwesomeOfSize(20)
    
    let barButtonItem: UIBarButtonItem
    weak var controller : UIViewController?
    
    init(presentingController controller: UIViewController) {
        self.controller = controller
        barButtonItem = UIBarButtonItem(title: String.fontAwesomeIconWithName(.EllipsisH), style: .Plain, target: nil, action: #selector(AboutActionsController.tappedMenu))
        barButtonItem.setTitleTextAttributes([NSFontAttributeName: AboutActionsController.buttonFont], forState: .Normal)
        super.init()
        barButtonItem.target = self
    }
    
    func tappedMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let donateAction = UIAlertAction(title: "Donate", style: .Default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/about/financial_support")
        }
        
        let aboutAction = UIAlertAction(title: "About", style: .Default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/about/")
        }
        
        let contactAction = UIAlertAction(title: "Contact", style: .Default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/contact/")
        }
        
        let cancel = UIAlertAction(title: "Close", style: .Cancel) { [weak self] (action) in
            self?.controller?.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
        alert.addAction(aboutAction)
        alert.addAction(donateAction)
        alert.addAction(contactAction)
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.barButtonItem = barButtonItem
        controller?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            let safariControler = SFSafariViewController(URL: url)
            self.controller?.presentViewController(safariControler, animated: true, completion: nil)
        }
    }
}
