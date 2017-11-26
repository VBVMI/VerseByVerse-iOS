//
//  Appearance.swift
//  VBVMI
//
//  Created by Thomas Carey on 27/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

enum Theme : Int
{
    case `default` = 0
    
    func applyTheme() {
        //UIButton.appearanceWhenContainedInInstancesOfClasses([UITableViewCell.self]).setTitleColor(StyleKit.darkGrey, forState: .Normal)
        //UILabel.appearanceWhenContainedInInstancesOfClasses([LessonTableViewCell.self]).textColor = StyleKit.darkGrey
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: StyleKit.darkGrey], for: UIControlState())
        UIBarButtonItem.appearance().tintColor = StyleKit.darkGrey
        
        
        UISegmentedControl.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = StyleKit.darkGrey
        TopicButton.appearance().tintColor = StyleKit.midGrey
    }
}
