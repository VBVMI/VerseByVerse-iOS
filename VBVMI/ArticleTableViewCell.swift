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
    
}
