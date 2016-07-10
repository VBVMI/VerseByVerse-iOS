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
    case Default = 0
    
    func applyTheme() {
        //UIButton.appearanceWhenContainedInInstancesOfClasses([UITableViewCell.self]).setTitleColor(StyleKit.darkGrey, forState: .Normal)
        //UILabel.appearanceWhenContainedInInstancesOfClasses([LessonTableViewCell.self]).textColor = StyleKit.darkGrey
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: StyleKit.darkGrey], forState: .Normal)
        UIBarButtonItem.appearance().tintColor = StyleKit.darkGrey
        
        
        UISegmentedControl.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self]).tintColor = StyleKit.darkGrey
        TopicButton.appearance().tintColor = StyleKit.midGrey
    }
}
