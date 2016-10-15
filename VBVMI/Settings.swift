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
            return UserDefaults.standard.bool(forKey: "autoMarkLessonsComplete")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "autoMarkLessonsComplete")
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate init() {
        
    }
    
}
