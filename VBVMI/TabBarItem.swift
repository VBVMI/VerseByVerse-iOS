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
    
    override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        if keyPath == "fontAwesomeKey" {
            if let value = value as? String {
                let scale = UIScreen.main.scale
                let pointSize: CGFloat = TabBar.pointSize
                if let icon = FontAwesome(rawValue: value) {
                    let icon = UIImage.fontAwesomeIcon(name: icon, style: .regular, textColor: StyleKit.white, size: CGSize(width: pointSize * scale, height: pointSize * scale))
                    self.image = icon
                }
            }
            return
        }
        super.setValue(value, forKeyPath: keyPath)
    }
}
