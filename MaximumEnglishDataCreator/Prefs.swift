//
//  Prefs.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/20.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

class Prefs: NSObject {
    
    static var DefaultFolder:URL {
        get {
            
            return UserDefaults.standard.url(forKey: "DefaultFolder") ?? URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "DefaultFolder")
            
        }
    }

}
