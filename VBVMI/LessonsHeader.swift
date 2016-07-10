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
    
    private let bottomSeparator = UIView()
    private let topSeparator = UIView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView() {
        self.contentView.addSubview(titleLabel)
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp_leftMargin)
            make.top.equalTo(self.contentView.snp_topMargin)
            //
            make.bottom.equalTo(self.contentView.snp_bottomMargin)
        }
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        titleLabel.textColor = StyleKit.darkGrey
        
        self.contentView.addSubview(countLabel)
        countLabel.snp_makeConstraints { (make) in
            make.baseline.equalTo(titleLabel.snp_baseline)
            make.right.equalTo(self.contentView.snp_rightMargin)
            make.left.equalTo(titleLabel.snp_right)
        }
        countLabel.textAlignment = .Right
        
        countLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        countLabel.textColor = StyleKit.darkGrey
        
        self.contentView.backgroundColor = StyleKit.white
        
        self.contentView.addSubview(bottomSeparator)
        bottomSeparator.backgroundColor = StyleKit.lightGrey
        bottomSeparator.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1.0 / UIScreen.mainScreen().scale)
        }
        
        self.contentView.addSubview(topSeparator)
        topSeparator.backgroundColor = StyleKit.lightGrey
        topSeparator.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(1.0 / UIScreen.mainScreen().scale)
        }
        
    }

}
