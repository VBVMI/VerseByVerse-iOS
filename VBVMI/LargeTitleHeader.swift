//
//  LargeTitleHeader.swift
//  VBVMI
//
//  Created by Thomas Carey on 5/04/20.
//  Copyright © 2020 Tom Carey. All rights reserved.
//

import UIKit

class LargeTitleHeader: UITableViewHeaderFooterView {

    private let titleView = UILabel(frame: .zero)
    
    var title: String? {
        get { return titleView.text }
        set { titleView.text = newValue }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }
    
    private func configureLayout() {
        
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.leftMargin)
            make.top.equalTo(contentView.snp.topMargin)
            make.bottom.equalTo(contentView.snp.bottomMargin)
            make.right.equalTo(contentView.snp.rightMargin)
        }
        
        titleView.font = UIFont.preferredFont(forTextStyle: .title1)
        titleView.textColor = UIColor.darkGray
    }

}
