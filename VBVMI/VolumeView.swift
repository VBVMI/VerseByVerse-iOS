//
//  VolumeView.swift
//  VBVMI
//
//  Created by Thomas Carey on 30/04/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import MediaPlayer

class VolumeView: MPVolumeView {

    let highVolumeImageView = UIImageView(image: UIImage(named: "volUp"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    fileprivate func configure() {
        self.addSubview(highVolumeImageView)
        highVolumeImageView.isHidden = self.areWirelessRoutesAvailable
        highVolumeImageView.contentMode = .center
        highVolumeImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(0)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let this = self else { return }
            this.highVolumeImageView.isHidden = this.areWirelessRoutesAvailable
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    let routeWidth : CGFloat = 21
    
    override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
        super.volumeSliderRect(forBounds: bounds)
        return CGRect(x: 0, y: 0, width: bounds.size.width - routeWidth, height: bounds.height)
    }
    
    override func routeButtonRect(forBounds bounds: CGRect) -> CGRect {
        super.routeButtonRect(forBounds: bounds)
        return CGRect(x: bounds.size.width - routeWidth, y: 0, width: routeWidth, height: bounds.height)
    }
    
}
