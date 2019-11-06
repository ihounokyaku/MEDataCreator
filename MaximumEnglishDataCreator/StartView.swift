//
//  ViewController.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/19.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

class StartVC: NSViewController, DropViewDelegate {

    @IBOutlet weak var dropView: FileDropView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dropView.delegate = self
        self.dropView.expectedExt = ["json"]
        self.dropView.displayText = "Drop JSON file here"
    }
    
    
    
    func didGetURL(url: URL, dropView: DropView) {
        guard let data = try? Data(contentsOf: url), let _ = try? JSON(data: data) else {
            self.dropView.displayText = "Not a valid JSON"
            return
        }
        
        self.presentCreateVC(withURL:url)
        
    }
    
    @IBAction func createNewPressed(_ sender: Any) {
        self.presentCreateVC(withURL:nil)
    }
    
    
    
    func presentCreateVC(withURL url:URL?) {
        
        let vc = NSStoryboard(name:"Main", bundle: nil).instantiateController(withIdentifier: "create") as! CreateVC
        vc.jsonManager = JSONManager(jsonURL: url)
        self.presentAsSheet(vc)
    }
    
    


}

