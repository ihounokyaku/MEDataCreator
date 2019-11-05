//
//  CreateVC.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/20.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

class CreateVC: NSViewController, DropViewDelegate {

    @IBOutlet weak var vocabDropView: FileDropView!
    @IBOutlet weak var grammarDropView: FileDropView!
    @IBOutlet weak var vocabTable: NSTableView!
    @IBOutlet weak var grammarTable: NSTableView!
    @IBOutlet weak var levelSelector: NSPopUpButton!
    @IBOutlet weak var lessonSelector: NSPopUpButton!
    @IBOutlet weak var levelUpButton: NSButton!
    @IBOutlet weak var levelDownButton: NSButton!
    @IBOutlet weak var lessonUpButton: NSButton!
    @IBOutlet weak var lessonDownButton: NSButton!
    @IBOutlet weak var levelAddButton: NSButton!
    @IBOutlet weak var levelRemoveButton: NSButton!
    @IBOutlet weak var lessonAddButton: NSButton!
    @IBOutlet weak var lessonRemoveButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    
    
    
    var selectedLevel:JSON? {
        let index = self.levelSelector.indexOfSelectedItem
        guard index >= 0, index < JSONManager.Levels.count else {return nil}
        return JSONManager.Levels[index]
        
    }
    
    var selectedLesson:JSON? {
        let index =  self.lessonSelector.indexOfSelectedItem
        guard let level = self.selectedLevel, index >= 0, index < JSONManager.Lessons(forLevel: level).count, JSONManager.Lessons(forLevel: level).count > self.lessonSelector.indexOfSelectedItem else {return nil}
        
        return JSONManager.Lessons(forLevel: level)[self.lessonSelector.indexOfSelectedItem]
        
    }
    
    var changed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JSONManager.Levels = JSONManager.JSONFile["levels"].arrayValue
        self.vocabDropView.delegate = self
        self.grammarDropView.delegate = self
        self.vocabTable.delegate = self
        self.vocabTable.dataSource = self
        self.grammarTable.delegate = self
        self.grammarTable.dataSource = self
        self.setLevelPicker()
    }
    
    func toggleButtons() {
        
        self.vocabDropView.isEnabled = self.selectedLesson != nil
        self.grammarDropView.isEnabled = self.selectedLesson != nil
        self.lessonRemoveButton.isEnabled = self.selectedLesson != nil
        self.lessonAddButton.isEnabled = self.selectedLevel != nil
        
        self.levelRemoveButton.isEnabled = self.selectedLevel != nil
        
        self.lessonUpButton.isEnabled = self.lessonSelector.indexOfSelectedItem < self.lessonSelector.numberOfItems - 1
        self.lessonDownButton.isEnabled = self.lessonSelector.indexOfSelectedItem > 0
        
        self.levelUpButton.isEnabled = self.levelSelector.indexOfSelectedItem < self.levelSelector.numberOfItems - 1
        self.levelDownButton.isEnabled = self.levelSelector.indexOfSelectedItem > 0
        
        self.saveButton.isEnabled = self.changed
        
    }
    
    func markChanged(){
        self.changed = true
        self.toggleButtons()
    }
    
    
    func setLevelPicker(selectIndex index:Int = 0) {
        
        self.levelSelector.removeAllItems()
        for level in JSONManager.Levels {
            
            self.levelSelector.addItem(withTitle: level["name"].string ?? "no name")
            
        }
        
        self.levelSelector.selectItem(at: index)
        
        self.setLessonPicker()
        
    }
    
    
    
    func setLessonPicker(selectIndex index:Int = 0) {
        self.lessonSelector.removeAllItems()
        
        guard let level = self.selectedLevel else { return }
        
        for item in JSONManager.Lessons(forLevel: level) {
            self.lessonSelector.addItem(withTitle: item["name"].string ?? "no name")
        }
        
        self.lessonSelector.selectItem(at: index)
        
        self.vocabTable.reloadData()
        self.grammarTable.reloadData()
        self.toggleButtons()
    }
    
    @IBAction func didChangeSelection(_ sender: NSPopUpButton) {
        if sender == self.levelSelector {
            self.setLessonPicker()
        } else {
            self.vocabTable.reloadData()
            self.grammarTable.reloadData()
        }
        self.toggleButtons()
    }
    
    @IBAction func addLevelPressed(_ sender: Any) {
        
        guard let levelName = Alert.GetUserInput(message: "Please choose a level name", placeholderText: "Beginner") else {return}
        let json:JSON = ["name":levelName, "lessons":[JSON]()]
        JSONManager.Levels.append(json)
        self.setLevelPicker(selectIndex: self.levelSelector.numberOfItems)
        self.markChanged()
    }
    
    @IBAction func addLessonPressed(_ sender: Any) {
        
        guard let lessonName = Alert.GetUserInput(message: "Please choose a lesson name", placeholderText: "Lesson - 1") else {return}
        var lessons = JSONManager.Levels[self.levelSelector.indexOfSelectedItem]["lessons"].arrayValue
        
        let newLesson:JSON = ["name":lessonName, "vocabulary":[JSON](), "grammar":[JSON]()]
        
       lessons.append(newLesson)
        JSONManager.Levels[self.levelSelector.indexOfSelectedItem]["lessons"] = JSON(lessons)
        
        self.setLessonPicker(selectIndex:self.lessonSelector.numberOfItems)
        
        self.markChanged()
    }
    
    @IBAction func removeLevelPressed(_ sender: Any) {
        guard self.selectedLevel != nil else { return }
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Level?") {
            
            JSONManager.Levels.remove(at: self.levelSelector.indexOfSelectedItem)
            
            self.setLevelPicker()
            self.markChanged()
        }
        
    }
    
    
    @IBAction func removeLessonPressed(_ sender: Any) {
        guard self.selectedLevel != nil else {return}
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Lesson?") {
            guard self.selectedLesson != nil else { return }
            var lessons = JSONManager.Lessons(forLevel: self.selectedLevel!)
            lessons.remove(at: self.lessonSelector.indexOfSelectedItem)
            JSONManager.Levels[self.levelSelector.indexOfSelectedItem]["lessons"] = JSON(lessons)
            
            self.setLevelPicker()
            self.markChanged()
        }
    }
    
    @IBAction func levelChangePressed(_ sender: NSButton) {
        
        guard self.selectedLevel != nil else { return }
        let amount = sender == self.levelUpButton ? 1 : -1
        let (adjustedArray, newIndex) = self.arrayChangingItemPosition(atIndex: self.levelSelector.indexOfSelectedItem, inArray: JSONManager.Levels, by: amount)
        JSONManager.Levels = adjustedArray
        self.setLevelPicker(selectIndex: newIndex)
        self.markChanged()
        
    }
    
    @IBAction func lessonChangePressed(_ sender: NSButton) {
        
        guard self.selectedLesson != nil else { return }
        let amount = sender == self.lessonUpButton ? 1 : -1
        let (adjustedArray, newIndex) = self.arrayChangingItemPosition(atIndex: self.lessonSelector.indexOfSelectedItem, inArray: JSONManager.Lessons(forLevel: self.selectedLevel!), by: amount)
        JSONManager.Levels[self.levelSelector.indexOfSelectedItem]["lessons"] = JSON(adjustedArray)
        
        self.setLessonPicker(selectIndex: newIndex)
        self.markChanged()
    }
    
    
    func arrayChangingItemPosition(atIndex index:Int, inArray array:[JSON], by amount:Int)-> ([JSON], Int){
        var newArray = array
        guard index + amount >= 0 && index + amount < newArray.count else { return (newArray, index)}
        let newIndex = index + amount
        let level = newArray.remove(at: index)
        newArray.insert(level, at: newIndex)
        return (newArray, newIndex)
    }
    
    
    func didGetURL(url: URL, dropView: DropView) {
        guard self.selectedLevel != nil else {
            dropView.displayText = "Drag File Here"
            return
        }
        guard let text = try? String(contentsOf: url) else {
            dropView.displayText = "cannot read url"
            return
        }
        
        var cards = [JSON]()
        
        let rows = text.components(separatedBy: "\n")
        for row in rows {
            var dic = [String:String]()
            let values = row.components(separatedBy: ",")
            if values.count == 2 {
                dic["question"] = values[0]
                dic["answer"] = values[1]
                cards.append(JSON(dic))
            }
            
        }
        
        if cards.count < 1 { return }
        
        let type = dropView == self.vocabDropView ? "vocabulary" : "grammar"
        
        var lessons = JSONManager.Levels[self.levelSelector.indexOfSelectedItem]["lessons"].arrayValue
        
        lessons[self.lessonSelector.indexOfSelectedItem][type] = JSON(cards)
        
        JSONManager.Levels[self.levelSelector.indexOfSelectedItem]["lessons"] = JSON(lessons)
        self.markChanged()
        self.vocabTable.reloadData()
        self.grammarTable.reloadData()
    }
    
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        JSONManager.JSONFile = JSON(["id":"\(Date().timeIntervalSince1970)", "levels":JSONManager.Levels as [JSON]])
        
        self.changed = false
        self.toggleButtons()
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        self.dismiss(self)
    }
    
}

extension CreateVC:NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let lesson = self.selectedLesson else {return 0}
        let cardType = tableView == self.vocabTable ? "vocabulary":"grammar"
       
        return lesson[cardType].arrayValue.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        guard let lesson = self.selectedLesson else { return cell}
        
        let field = tableColumn!.identifier.rawValue.lowercased()
        let cardType = tableView == self.vocabTable ? "vocabulary":"grammar"
        let card = lesson[cardType].arrayValue[row]
       
        cell.textField?.stringValue = card[field].stringValue

        return cell
    }
    
    
}
