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
    @IBOutlet private weak var dateLabel: UILabel!
    
    weak var delegate : RecentStudyCollectionViewCellDelegate?
    
    private let overlayView = UIView(frame: .zero)
    private let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    
    var dateLabelText: String? {
        set {
            dateLabel.text = newValue
            dateLabel.isHidden = newValue?.count ?? 0 == 0
        }
        get {
            return dateLabel.text
        }
    }
    
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
        
        dateLabelText = nil
        
        nextButton.addTarget(self, action: #selector(didSelectNext), for: .touchUpInside)
        
        contentView.addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        overlayView.layer.cornerRadius = 4
        overlayView.backgroundColor = UIColor(hue: 1, saturation: 0, brightness: 0, alpha: 0.4)
        overlayView.addSubview(activityView)
        activityView.color = StyleKit.orange
        
        activityView.snp.makeConstraints { (make) in
            make.center.equalTo(imageView)
        }
        
        applyLoading()
    }
    
    var isLoading: Bool = false {
        didSet {
            applyLoading()
        }
    }
    
    private func applyLoading() {
        if isLoading {
            activityView.startAnimating()
            overlayView.isHidden = false
        } else {
            activityView.stopAnimating()
            overlayView.isHidden = true
        }
    }

    @objc private func didSelectNext() {
        delegate?.didSelectNext(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        dateLabelText = nil
        isLoading = false
    }
}
