//
//  FileDropView.swift
//  movieFiler
//
//  Created by Dylan Southard on 2018/01/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class MixDropView: DropView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
            }
    
    
    override func setType() { self.dropViewType = .mixed }
    
    var expectedExt = [String]()
    
    override func checkExtension(_ drag: NSDraggingInfo) -> Bool {
       
        if let url = self.getUrl(drag) {
            let suffix = url.pathExtension
            
            if url.hasDirectoryPath {
                
                return true
                
            }
            
            for ext in self.expectedExt {
                if ext.lowercased() == suffix {
                    
                    return true
                }
            }
        }
       
        return false
    }
    
   
    
}
