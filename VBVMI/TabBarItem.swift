//
//  AnswersTabBarItem.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import FontAwesome_swift

class TabBarItem: UITabBarItem {
    
    override func setValue(value: AnyObject?, forKeyPath keyPath: String) {
        if keyPath == "fontAwesomeKey" {
            if let value = value as? String {
                let scale = UIScreen.mainScreen().scale
                let pointSize: CGFloat = TabBar.pointSize
                if let raw = FontAwesomeIcons[value], let icon = FontAwesome(rawValue: raw) {
                    let icon = UIImage.fontAwesomeIconWithName(icon, textColor: StyleKit.white, size: CGSize(width: pointSize * scale, height: pointSize * scale))
                    self.image = icon
                }
            }
            return
        }
        super.setValue(value, forKeyPath: keyPath)
    }
}