//
//  WebViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 25/07/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import WebKit

protocol ObjectURIRepresentable {
    var objectURIRepresentation: URL { get }
}

extension NSManagedObject : ObjectURIRepresentable {
    var objectURIRepresentation: URL {
        return objectID.uriRepresentation()
    }
}

protocol WebViewable : ObjectURIRepresentable {
    var webDisplayTitle: String { get }
    var webBodyContent: String { get }
    var webShareURL: String? { get }
}

class WebViewController: UIViewController {

    private var viewable: WebViewable
    
    private lazy var webView : WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    init(viewable: WebViewable) {
        self.viewable = viewable
        super.init(nibName: nil, bundle: nil)
        restorationIdentifier = "org.versebyverseministry.WebViewController"
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        
        if let objectURL = aDecoder.decodeObject(forKey: "viewableURL") as? URL,
           let objectId = context?.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: objectURL),
           let viewable = (try? context?.existingObject(with: objectId)) as? WebViewable {
            self.viewable = viewable
            super.init(coder: aDecoder)
            restorationIdentifier = "org.versebyverseministry.WebViewController"
            configureViews()
        } else {
            return nil
        }
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(viewable.objectURIRepresentation, forKey: "viewableURL")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    func configureViews() {
        
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        navigationItem.title = viewable.webDisplayTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDone))
    }
 
    @objc
    private func tappedDone() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController : WKNavigationDelegate {
    
}

extension WebViewController : WKUIDelegate {
    
}
