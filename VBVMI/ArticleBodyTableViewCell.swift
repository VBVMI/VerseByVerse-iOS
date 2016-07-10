//
//  ArticleBodyTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 18/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class ArticleBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    var hasImage = false {
        didSet {
            authorImageView.hidden = !hasImage
            if hasImage {
                let ratio = imageViewAspectRatioConstraint.multiplier
                let width = self.imageViewWidthConstraint.constant
                var rect = CGRectMake(0, 0, width, width / ratio)
                rect = rect.insetBy(dx: -8, dy: 0)
                let bezierPath = UIBezierPath(rect: rect)
                
                authorImageView.layer.cornerRadius = 3
                authorImageView.layer.masksToBounds = true
                bodyTextView.textContainer.exclusionPaths = [bezierPath]
            } else {
                bodyTextView.textContainer.exclusionPaths = []
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func setAuthorImage(image: UIImage?) -> () {
//        if let myImage = image, size = image?.size where size.width > 0 && size.height > 0 {
//            authorImageView.hidden = false
//            authorImageView.image = myImage
//            
//            
//        } else {
//            authorImageView.hidden = true
//            authorImageView.image = nil
//            bodyTextView.textContainer.exclusionPaths = []
//        }
//    }
    
}
