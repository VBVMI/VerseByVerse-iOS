//
//  Settings.swift
//  VBVMI
//
//  Created by Thomas Carey on 28/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation

class Settings {
    
    static let sharedInstance = Settings()
    
    var autoMarkLessonsComplete : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("autoMarkLessonsComplete")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "autoMarkLessonsComplete")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private init() {
        
    }
    
}
