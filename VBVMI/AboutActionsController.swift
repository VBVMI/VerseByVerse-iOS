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

    fileprivate static let buttonFont = UIFont.fontAwesomeOfSize(20)
    
    let barButtonItem: UIBarButtonItem
    weak var controller : UIViewController?
    
    init(presentingController controller: UIViewController) {
        self.controller = controller
        barButtonItem = UIBarButtonItem(image: UIImage.fontAwesomeIconWithName(.EllipsisH, textColor: StyleKit.darkGrey, size: CGSize(width: 30, height: 30)), style: UIBarButtonItemStyle.plain, target: nil, action: #selector(AboutActionsController.tappedMenu))
        super.init()
        barButtonItem.target = self
    }
    
    func tappedMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let donateAction = UIAlertAction(title: "Donate", style: .default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/about/financial_support")
        }
        
        let aboutAction = UIAlertAction(title: "About", style: .default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/about/")
        }
        
        let eventsAction = UIAlertAction(title: "Events", style: .default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/events/")
        }
        
        let contactAction = UIAlertAction(title: "Contact", style: .default) { [weak self] (action) in
            self?.openURL("https://www.versebyverseministry.org/contact/")
        }
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { [weak self] (action) in
            let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
            if let viewController = settingsStoryboard.instantiateInitialViewController() {
                self?.controller?.present(viewController, animated: true, completion: nil)
            }
        }
        
        let cancel = UIAlertAction(title: "Close", style: .cancel) { [weak self] (action) in
            self?.controller?.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(aboutAction)
        alert.addAction(eventsAction)
        alert.addAction(contactAction)
        alert.addAction(donateAction)
        alert.addAction(settingsAction)
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.barButtonItem = barButtonItem
        controller?.present(alert, animated: true, completion: nil)
    }
    
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            let safariControler = SFSafariViewController(url: url)
            self.controller?.present(safariControler, animated: true, completion: nil)
        }
    }
}
