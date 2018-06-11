//
//  RecentStudyCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 9/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit

protocol RecentStudyCollectionViewCellDelegate : class {
    func didSelectNext(cell: RecentStudyCollectionViewCell)
}

class RecentStudyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate : RecentStudyCollectionViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nextButton.layer.borderColor = UIColor.white.cgColor
        nextButton.layer.cornerRadius = 4
        nextButton.layer.borderWidth = 1
        
        contentView.backgroundColor = UIColor(hue: 1, saturation: 0, brightness: 1, alpha: 0.08)
        contentView.layer.cornerRadius = 4
        
        self.selectedBackgroundView = UIView(frame: .zero)
        self.selectedBackgroundView?.backgroundColor = UIColor(hue: 1, saturation: 0, brightness: 1, alpha: 0.12)
        self.selectedBackgroundView?.layer.cornerRadius = 6
        
        nextButton.addTarget(self, action: #selector(didSelectNext), for: .touchUpInside)
    }

    @objc private func didSelectNext() {
        delegate?.didSelectNext(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
}
