

import Cocoa

protocol DropViewDelegate {
    
    func didGetURL(url:URL, dropView:DropView)
    
}

extension DropViewDelegate {
    
    func didGetURL(url:URL, dropView:DropView){}
    
}

enum DropViewType:String {
    
    case file = "file"
    case folder = "folder"
    case mixed = "mixed"
    
}


class DropView: NSView {
    
    lazy var label:NSTextField = {
        let textField = NSTextField()
        textField.frame.size = CGSize(width: self.frame.width - 10, height: 30)
        let originX = (self.bounds.width / 2) - (textField.frame.width / 2)
        let originY = (self.bounds.height / 2) - (textField.frame.height / 2)
        textField.frame.origin = CGPoint(x: originX, y: originY)
        textField.isEditable = false
        textField.alignment = .center
        textField.stringValue = self.displayText
        return textField
        
    }()
    
    var isEnabled = true
    
    var delegate:DropViewDelegate?
    
    var filePath: String?
    
    var dropViewType:DropViewType!
    
    var displayText:String = "Drag File Here" {
        didSet {
            self.label.stringValue = self.displayText
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        self.setType()
    }
    
    func setType() {}
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.addSubview(self.label)
        
        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if self.isEnabled && checkExtension(sender) {
            
            self.layer?.backgroundColor = NSColor.blue.cgColor
            return .copy
            
        } else {
            
            return NSDragOperation()
            
        }
    }
    
    func getUrl(_ drag: NSDraggingInfo)-> URL? {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return nil}
        
        return URL(fileURLWithPath: path)
    }
    
    func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        
        return false
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let url =  self.getUrl(sender)!
        self.delegate?.didGetURL(url: url, dropView: self)
        self.displayText = url.path
        return true
    }
    
    
}

