//
//  LessonsHeader.swift
//  VBVMI
//
//  Created by Thomas Carey on 21/05/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class LessonsHeader: UITableViewHeaderFooterView {

    let titleLabel = UILabel()
    let countLabel = UILabel()
    
    fileprivate let bottomSeparator = UIView()
    fileprivate let topSeparator = UIView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    fileprivate func configureView() {
        self.contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.leftMargin)
            make.top.equalTo(self.contentView.snp.topMargin)
            //
            make.bottom.equalTo(self.contentView.snp.bottomMargin).priority(UILayoutPriorityRequired - 10)
        }
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        titleLabel.textColor = StyleKit.darkGrey
        
        self.contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(titleLabel.snp.firstBaseline)
            make.right.equalTo(self.contentView.snp.rightMargin)
            make.left.equalTo(titleLabel.snp.right).priority(UILayoutPriorityRequired - 10)
        }
        countLabel.textAlignment = .right
        
        countLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        countLabel.textColor = StyleKit.darkGrey
        
        self.contentView.backgroundColor = StyleKit.white
        
        self.contentView.addSubview(bottomSeparator)
        bottomSeparator.backgroundColor = StyleKit.lightGrey
        bottomSeparator.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        
        self.contentView.addSubview(topSeparator)
        topSeparator.backgroundColor = StyleKit.lightGrey
        topSeparator.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        
    }

}
