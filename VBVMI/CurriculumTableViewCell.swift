//
//  CurriculumTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 22/08/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit

class CurriculumTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = StyleKit.darkGrey
        countLabel.textColor = StyleKit.darkGrey
        dateLabel.textColor = StyleKit.midGrey
        thumbnailImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
