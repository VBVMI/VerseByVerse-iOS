//
//  FlagView.swift
//  VBVMI
//
//  Created by Thomas Carey on 16/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit

class FlagView: UIView {

    private let label = UILabel(frame: .zero)
    
    public var title: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView() {
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(4)
            make.left.equalTo(4)
            make.right.equalTo(-4)
            make.bottom.equalTo(-4)
        }
        
        snp.makeConstraints { (make) in
            make.width.equalTo(80).priority(500)
        }
        label.textAlignment = .right
//        self.layer.cornerRadius = 2
//        self.layer.borderWidth = 1
//        self.layer.borderColor = StyleKit.orange.cgColor
        
        label.textColor = StyleKit.orange
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    }
    
    override var firstBaselineAnchor: NSLayoutYAxisAnchor {
        return label.firstBaselineAnchor
    }
    
    override var lastBaselineAnchor: NSLayoutYAxisAnchor {
        return label.lastBaselineAnchor
    }
    
    override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        return CGSize(width: size.width + 8, height: size.height + 8)
    }
    
}
