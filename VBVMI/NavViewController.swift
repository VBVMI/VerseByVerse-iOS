//
//  NavViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 28/07/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit

protocol HidableStatusbarController: class {
    var shouldHideStatusBar: Bool { get set }
    
    func setNeedsStatusBarAppearanceUpdate()
}

class NavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        restorationIdentifier = "org.versebyverseministry.NavViewController"
        restorationClass = NavViewController.self
        // Do any additional setup after loading the view.
        
        self.barHideOnSwipeGestureRecognizer.addTarget(self, action: #selector(swipe(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewControllers.last?.supportedInterfaceOrientations ?? .all
    }

    @objc private func swipe(_ gestureRecognizer: UIGestureRecognizer) {
        
        let shouldHideStatusBar = self.navigationBar.frame.origin.y < 0
        if let controller = viewControllers.last as? HidableStatusbarController {
            controller.shouldHideStatusBar = shouldHideStatusBar
            UIView.animate(withDuration: 0.2) {
                controller.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NavViewController: UIViewControllerRestoration {
    static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        return NavViewController(coder: coder)
    }
}
