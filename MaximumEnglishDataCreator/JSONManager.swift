//
//  LibraryCatalogManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/11.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON



enum LevelName:String, CaseIterable {
    
    case beginner = "Beginner"
    case lowerIntermediate = "Lower Intermediate"
    case intermediate = "Intermediate"
    case upperIntermediate = "Upper Intermediate"
    case advanced = "Advanced"
    
}

//MARK: - =============== KEYS ===============
enum JSONKey {
    
    case jsonID
    case levels
    case lessons
    case levelID
    case lessonID
    case lessonName
    case vocabularyCards
    case grammarCards
    case cardID
    case question
    case answer
    case notes
    
    func keyValue()->String {
        
        switch self {
            
        case .jsonID, .lessonID:
            return "id"
        case .levels:
            return "levels"
        case .lessons:
            return "lessons"
        case .levelID, .lessonName:
            return "name"
        case .vocabularyCards:
            return "vocabulary"
        case .grammarCards:
            return "grammar"
        case .cardID, .question:
            return "question"
        case .answer:
            return "answer"
        case .notes:
            return "notes"
        }
        
    }
}

enum CardType {
    
    case vocab
    case grammar
    
    func stringValue()->String {
        switch self {
        case .vocab:
            return JSONKey.vocabularyCards.keyValue()
        case .grammar:
            return JSONKey.grammarCards.keyValue()
            
        }
    }
    
}

class JSONManager: NSObject {
    
    var json:JSON
    
    var jsonURL:URL?
    
    init(jsonURL:URL?) {
        
        
        if let url = jsonURL, let data = try? Data(contentsOf: url), let realJSON = try? JSON(data: data), realJSON[JSONKey.levels.keyValue()].array != nil {
            
            self.jsonURL = url
            self.json = realJSON
            
        } else {
            
            self.json = JSON()
            
        }
        
        super.init()
        
        self.populateLevels()
        
    }
    
    func populateLevels() {
        
        let levelNames = self.levels.map { $0[JSONKey.levelID.keyValue()].stringValue }
        var levels = [JSON]()
        
        for levelName in LevelName.allCases {
            if levelNames.contains(levelName.rawValue) {
                
                levels.append(self.levels[levelNames.firstIndex(of: levelName.rawValue)!])
                
            } else {
                
                levels.append(JSON([JSONKey.levelID.keyValue():JSON(levelName.rawValue)]))
                
            }
                
        }
        
        json[JSONKey.levels.keyValue()] = JSON(levels)
        
    }
    
   
    func setLessons(_ lessons:[JSON], forLevelAtIndex index:Int) {
        
        guard self.levels.count > index else {
            print("levels less \(self.levels.count) vs \(index)")
            return
            
        }
        
        self.json[JSONKey.levels.keyValue()][index][JSONKey.lessons.keyValue()] = JSON(lessons)
        
    }
    
    func setNotes(_ notes:String, forLessonAtIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int) {
        
        guard self.lessonExists(atIndex: lessonIndex, inLevelAtIndex: levelIndex) else { return }
        
        self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.lessons.keyValue()][lessonIndex][JSONKey.notes.keyValue()] = JSON(notes)
        
    }
    
    func setCards(_ cards:[JSON], ofType type:String, forLessonAtIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int) {
        
        guard self.lessonExists(atIndex: lessonIndex, inLevelAtIndex: levelIndex) else { return }
        
        self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.lessons.keyValue()][lessonIndex][type] = JSON(cards)
        
    }
    
    func editCard(ofType type:String, atIndex cardIndex:Int, inLessonAtIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int, newValue:String, forProperty property:String) {
        
        guard self.lessonExists(atIndex: lessonIndex, inLevelAtIndex: levelIndex) else { return }
        
        var cards = self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.lessons.keyValue()][lessonIndex][type].arrayValue
        
        if cards.count > cardIndex {
            
            cards[cardIndex][property] = JSON(newValue)
            
        } else {
            
            cards.append(JSON([property:newValue]))
            
        }
        
        self.setCards(cards, ofType: type, forLessonAtIndex: lessonIndex, inLevelAtIndex: levelIndex)
        
    }
    
    func lessonExists(atIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int)-> Bool {
        
        return self.levels.count > levelIndex && self.lessons(forLevel: self.levels[levelIndex]).count > lessonIndex
    }

    
    var levels:[JSON] { return self.json[JSONKey.levels.keyValue()].arrayValue }
    
    func lessons(forLevel level:JSON)-> [JSON] { return level[JSONKey.lessons.keyValue()].arrayValue }
    
    func vocabulary(forLesson lesson:JSON)->[JSON] { return lesson[JSONKey.vocabularyCards.keyValue()].arrayValue }
    
    func grammar(forLesson lesson:JSON)->[JSON] { return lesson[JSONKey.grammarCards.keyValue()].arrayValue }
    

    func writeFile() {
        var fileURL = self.jsonURL
        if fileURL == nil {
            var count = 1
            let originalFileName = "MEJSONData"
            var newURL = Prefs.DefaultFolder.appendingPathComponent(originalFileName + ".json")
            while newURL.fileExists {
                let newName = originalFileName + "-" + String(format: "%2d", count)
                newURL = Prefs.DefaultFolder.appendingPathComponent(newName + ".json")
                count += 1
            }
            
            fileURL = newURL
        }
        
        guard let nv = self.json.rawString(), let realURL = fileURL, realURL.isFileURL else {
            
            Alert.PresentErrorAlert(text: "Error updating file")
            
            return
            
        }
        
        FileManager.WriteTextToFile(text: nv, toFolder: realURL.deletingLastPathComponent(), fileName: realURL.lastPathComponent)
        
    }
}
