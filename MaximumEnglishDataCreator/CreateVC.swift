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
    @IBOutlet weak var lessonUpButton: NSButton!
    @IBOutlet weak var lessonDownButton: NSButton!
    @IBOutlet weak var lessonAddButton: NSButton!
    @IBOutlet weak var lessonRemoveButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    
    var jsonManager:JSONManager!
    
    var selectedLevel:JSON? {
        let index = self.levelSelector.indexOfSelectedItem
        guard index >= 0, index < self.jsonManager.levels.count else {return nil}
        return self.jsonManager.levels[index]
        
    }
    
    var selectedLevelName:LevelName {
        var index = self.levelSelector.indexOfSelectedItem
        if LevelName.allCases.count > index {
            
            index = LevelName.allCases.count - 1
            
        }
        return LevelName.allCases[index]
        
    }
    
    var selectedLesson:JSON? {
        let index =  self.lessonSelector.indexOfSelectedItem
        guard let level = self.selectedLevel, index >= 0, index < self.jsonManager.lessons(forLevel: level).count, self.jsonManager.lessons(forLevel: level).count > self.lessonSelector.indexOfSelectedItem else {return nil}
        
        return self.jsonManager.lessons(forLevel: level)[self.lessonSelector.indexOfSelectedItem]
        
    }
    
    var lessons:[JSON] {
        
        guard self.selectedLevel != nil else {return [JSON]()}
        return self.jsonManager.lessons(forLevel: self.jsonManager.levels[self.levelSelector.indexOfSelectedItem])
        
    }
    
    var changed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.lessonUpButton.isEnabled = self.lessonSelector.indexOfSelectedItem < self.lessonSelector.numberOfItems - 1
        self.lessonDownButton.isEnabled = self.lessonSelector.indexOfSelectedItem > 0
        
        self.saveButton.isEnabled = self.changed
        
    }
    
    func markChanged(){
        self.changed = true
        self.toggleButtons()
    }
    
    
    func setLevelPicker(selectIndex index:Int = 0) {
        
        self.levelSelector.removeAllItems()
        for level in LevelName.allCases {
            
            self.levelSelector.addItem(withTitle: level.rawValue)
            
        }
        
        self.levelSelector.selectItem(at: index)
        
        self.setLessonPicker()
        
    }
    
    
    
    func setLessonPicker(selectIndex index:Int = 0) {
        self.lessonSelector.removeAllItems()
        
        guard let level = self.selectedLevel else { return }
        
        for item in self.jsonManager.lessons(forLevel: level) {
            self.lessonSelector.addItem(withTitle: item[JSONKey.lessonName.keyValue()].string ?? "no name")
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
    
    @IBAction func addLessonPressed(_ sender: Any) {
        
        guard let lessonName = Alert.GetUserInput(message: "Please choose a lesson name", placeholderText: "Lesson - 1") else {return}
        print("lesson chosen")
        var lessons = self.lessons
        
        let newLesson:JSON = [JSONKey.lessonID.keyValue():"\(lessonName)\(Date().timeIntervalSince1970)", JSONKey.lessonName.keyValue():lessonName, JSONKey.vocabularyCards.keyValue():[JSON](), JSONKey.grammarCards.keyValue():[JSON]()]
        
       lessons.append(newLesson)
        
        self.jsonManager.setLessons(lessons, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        
        self.setLessonPicker(selectIndex:self.lessonSelector.numberOfItems)
        
        self.markChanged()
    }
    
    
    
    @IBAction func removeLessonPressed(_ sender: Any) {
        
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Lesson?") {
            guard self.selectedLesson != nil else { return }
            var lessons = self.lessons
            lessons.remove(at: self.lessonSelector.indexOfSelectedItem)
            
            self.jsonManager.setLessons(lessons, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
            
            self.setLevelPicker()
            self.markChanged()
        }
    }
    
    
    @IBAction func lessonChangePressed(_ sender: NSButton) {
        
        guard self.selectedLesson != nil else { return }
        let amount = sender == self.lessonUpButton ? 1 : -1
        let (adjustedArray, newIndex) = self.arrayChangingItemPosition(atIndex: self.lessonSelector.indexOfSelectedItem, inArray: self.jsonManager.lessons(forLevel: self.selectedLevel!), by: amount)
        self.jsonManager.setLessons(adjustedArray, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        
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
        guard self.selectedLevel != nil, self.selectedLesson != nil  else {
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
                dic[JSONKey.question.keyValue()] = values[0]
                dic[JSONKey.answer.keyValue()] = values[1]
                cards.append(JSON(dic))
            }
            
        }
        
        if cards.count < 1 { return }
        
        let type = dropView == self.vocabDropView ? JSONKey.vocabularyCards.keyValue() : JSONKey.grammarCards.keyValue()
        
        jsonManager.setCards(cards, ofType: type, forLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        
        self.markChanged()
        self.vocabTable.reloadData()
        self.grammarTable.reloadData()
    }
    
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        self.jsonManager.json[JSONKey.jsonID.keyValue()] = JSON("\(Date().timeIntervalSince1970)")
        self.jsonManager.writeFile()
        
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
        let cardType = tableView == self.vocabTable ? JSONKey.vocabularyCards.keyValue():JSONKey.grammarCards.keyValue()
       
        return lesson[cardType].arrayValue.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        guard let lesson = self.selectedLesson else { return cell}
        
        let field = tableColumn!.identifier.rawValue.lowercased()
        let cardType = tableView == self.vocabTable ? JSONKey.vocabularyCards.keyValue():JSONKey.grammarCards.keyValue()
        let card = lesson[cardType].arrayValue[row]
       
        cell.textField?.stringValue = card[field].stringValue

        return cell
    }
    
    
}
