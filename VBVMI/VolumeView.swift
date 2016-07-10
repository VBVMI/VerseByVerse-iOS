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
    
    private func configure() {
        self.addSubview(highVolumeImageView)
        highVolumeImageView.hidden = self.wirelessRoutesAvailable
        highVolumeImageView.contentMode = .Center
        highVolumeImageView.snp_makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.snp_centerY)
            make.right.equalTo(0)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(MPVolumeViewWirelessRoutesAvailableDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) in
            guard let this = self else { return }
            this.highVolumeImageView.hidden = this.wirelessRoutesAvailable
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    let routeWidth : CGFloat = 21
    
    override func volumeSliderRectForBounds(bounds: CGRect) -> CGRect {
        super.volumeSliderRectForBounds(bounds)
        return CGRect(x: 0, y: 0, width: bounds.size.width - routeWidth, height: bounds.height)
    }
    
    override func routeButtonRectForBounds(bounds: CGRect) -> CGRect {
        super.routeButtonRectForBounds(bounds)
        return CGRect(x: bounds.size.width - routeWidth, y: 0, width: routeWidth, height: bounds.height)
    }
    
}
