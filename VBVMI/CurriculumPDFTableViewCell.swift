//
//  CurriculumPDFTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 26/08/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit


protocol CurriculumPDFTableViewCellDelegate: class {
    func orderCopies(cell: CurriculumPDFTableViewCell)
}

class CurriculumPDFTableViewCell: UITableViewCell {
    @IBOutlet weak var pdfImageView: UIImageView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var orderCopiesButton: UIButton!
    
    weak var delegate: CurriculumPDFTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        downloadLabel.textColor = StyleKit.darkGrey
        orderCopiesButton.addTarget(self, action: #selector(orderCopiesTapped), for: .touchUpInside)
        
        pdfImageView.layer.cornerRadius = 3
        pdfImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func orderCopiesTapped() {
        
        delegate?.orderCopies(cell: self)
    }
    
}
