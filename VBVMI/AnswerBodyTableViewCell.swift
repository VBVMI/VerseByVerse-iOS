//
//  AnswerBodyTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 19/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class AnswerBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var bodyTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
