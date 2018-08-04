//
//  ArticleTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 17/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topicLayoutView: TopicLayoutView!
    @IBOutlet weak var summaryLabel: UILabel!
    
    
    var summaryText: String? {
        get {
            return summaryLabel.text
        }
        set {
            summaryLabel.text = newValue
            if let newValue = newValue, newValue.count > 0 {
                summaryLabel.isHidden = false
            } else {
                summaryLabel.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        topicTextView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        authorLabel.textColor = StyleKit.darkGrey
        dateLabel.textColor = StyleKit.midGrey
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorLabel.text = nil
        dateLabel.text = nil
        topicLayoutView.topics = []
        summaryText = nil
    }
    
}
