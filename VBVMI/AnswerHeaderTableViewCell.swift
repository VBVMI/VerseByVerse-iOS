//
//  AnswerHeaderTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 19/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class AnswerHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var postedDateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
