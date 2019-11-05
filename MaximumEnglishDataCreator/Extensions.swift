//
//  Extensions.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/20.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import SwiftyJSON

extension URL {
    
    var fileExists:Bool {
        
        let path = self.path
        
        if FileManager.default.fileExists(atPath: path) {return true}
        
        return false
        
    }
    
}

extension FileManager {
    
    static func WriteTextToFile(text:String, toFolder folder:URL, fileName:String) {
        
        do {
            
            try text.write(to: folder.appendingPathComponent(fileName), atomically: false, encoding: .utf8)
            
        } catch let error {
            
            Alert.PresentErrorAlert(text: "Error saving file: \(fileName)!" + error.localizedDescription)
            
        }
        
    }
    
    static func ReadJSON(atURL url: URL ) -> JSON? {
        
        guard let data = try? Data(contentsOf: url), let json = try? JSON(data:data) else {return nil}
        
        return json
        
    }
    
    
    
}


