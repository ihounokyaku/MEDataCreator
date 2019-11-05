//
//  ErrorHandling.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/05.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa


class Alert:NSObject {
    
    static func PresentErrorAlert(text:String) {
        
        let alert = NSAlert()
        alert.messageText = text
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        let _ = alert.runModal()
        
    }
    
    static func GetUserInput(message:String, placeholderText:String?)->String? {
        
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")      // 1st button
        alert.addButton(withTitle: "Cancel")  // 2nd button
        alert.messageText = message
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = placeholderText ?? ""
        //self.textField = txt
        alert.accessoryView = txt
        let response: NSApplication.ModalResponse = alert.runModal()
        
       
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            
            return txt.stringValue
            
        }
        
        return nil
    }
    
    static func PresentConfirmationAlert(text:String)->Bool {
        
        let alert = NSAlert()
        alert.messageText = text
        alert.addButton(withTitle: "OK")      // 1st button
        alert.addButton(withTitle: "Cancel")  // 2nd button
        let response: NSApplication.ModalResponse = alert.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            
            return true
            
        }
        return false
        
    }
    
    
}
