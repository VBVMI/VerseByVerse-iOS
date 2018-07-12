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

    //var bottomConstraint: NSLayoutConstraint!
    
    private var heightConstraint: NSLayoutConstraint!
    
    var descriptionLabel = UITextView(frame: .zero)
    @IBOutlet var hideView: HideView!
    @IBOutlet var moreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(descriptionLabel, at: 0)
//        descriptionLabel.numberOfLines = 0
        descriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true

        descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        descriptionLabel.isScrollEnabled = false
        descriptionLabel.isEditable = false
        
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 100)
        heightConstraint.priority = UILayoutPriority(1000)
        heightConstraint.isActive = true
    }
    
    enum Mode {
        case content
        case short
    }
    
    var mode: Mode = .short {
        didSet {
            switch mode {
            case .short:
                heightConstraint.constant = 100
//                heightConstraint.isActive = true
            case .content:
                heightConstraint.constant = descriptionLabel.bounds.size.height + 5
//                heightConstraint.isActive = false
            }
        }
    }
}
