//
//  AutoSizingWebView.swift
//  VBVMI
//
//  Created by Thomas Carey on 21/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import Foundation
import WebKit

class AutoSizingWebView: WKWebView {
    
    init(frame: CGRect) {
        let config = WKWebViewConfiguration()
        super.init(frame: frame, configuration: config)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        print("😢 Size: \(self.scrollView.contentSize)")
        return self.scrollView.contentSize
    }
    
}
