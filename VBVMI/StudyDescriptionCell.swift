//
//  StudyDescriptionCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import WebKit

class StudyDescriptionCell: UITableViewCell {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var descriptionView: WKWebView!
    @IBOutlet var hideView: HideView!
    @IBOutlet var moreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionView = AutoSizingWebView(frame: .zero)
        contentView.insertSubview(descriptionView, at: 0)
        descriptionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        descriptionView.navigationDelegate = self
        
        descriptionView.scrollView.isScrollEnabled = false
    }
    
}

extension StudyDescriptionCell : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState") { (_,_) in
            webView.invalidateIntrinsicContentSize()
        }
        webView.invalidateIntrinsicContentSize()
//        (superview as? UITableView)?.beginUpdates()
//        (superview as? UITableView)?.endUpdates()
    }
}
