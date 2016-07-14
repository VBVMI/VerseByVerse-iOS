//
//  ChannelTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 10/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = StyleKit.darkGrey
        countLabel.textColor = StyleKit.darkGrey
        dateLabel.textColor = StyleKit.midGrey
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
