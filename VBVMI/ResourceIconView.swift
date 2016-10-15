//
//  ResourceIconView.swift
//  VBVMI
//
//  Created by Thomas Carey on 21/05/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import FontAwesome_swift
import ACPDownload

class ResourceIconView: UIView {

    let button = ACPDownloadView(frame: CGRect.zero)
    let dotView = DotView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = UIColor.clear
        self.button.backgroundColor = UIColor.clear
        
        addSubview(button)
        button.snp_makeConstraints { (make) in
            make.center.equalTo(snp_center)
            make.width.height.equalTo(30)
        }
        
        addSubview(dotView)
        dotView.snp_makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.centerX.equalTo(self.snp_centerX)
        }
        
        self.snp_makeConstraints { (make) in
            make.width.equalTo(50).priority(UILayoutPriorityRequired - 10)
            make.height.equalTo(44)
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 50, height: 44)
    }
}
