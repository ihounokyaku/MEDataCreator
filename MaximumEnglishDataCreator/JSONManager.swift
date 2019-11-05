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
        }
        
    }
}

class JSONManager: NSObject {
    
    static var JSONFileURL:URL?
    
    static var JSONFile:JSON {
        
        get {
            
            var url = JSONFileURL
            
            
            if url == nil {
                var count = 1
                let originalFileName = "InitialData"
                var newURL = Prefs.DefaultFolder.appendingPathComponent(originalFileName + ".json")
                while newURL.fileExists {
                    let newName = originalFileName + "-" + String(format: "%2d", count)
                    newURL = Prefs.DefaultFolder.appendingPathComponent(newName + ".json")
                    count += 1
                }
                JSONFileURL = newURL
                url = newURL
            }
            
            
            if url!.isFileURL {
                
                if !url!.fileExists {
                    
                    let json:JSON = [:]
                    
                    FileManager.WriteTextToFile(text: json.rawString()!, toFolder: Prefs.DefaultFolder, fileName: url!.lastPathComponent)
                    
                }
                
                return FileManager.ReadJSON(atURL: url!) ?? [:]
                
            }
        
            return [:]

        }
        
        set {
            guard let nv = newValue.rawString(), let fileURL = JSONFileURL, fileURL.isFileURL else {
                
                Alert.PresentErrorAlert(text: "Error updating file")
                
                return
                
            }
            
            FileManager.WriteTextToFile(text: nv, toFolder: fileURL.deletingLastPathComponent(), fileName: fileURL.lastPathComponent)
            
        }
        
    }
    
    
    static private var InitiatedLevels:[JSON]?
    
    static var Levels:[JSON]!
    
    static func Lessons(forLevel level:JSON)-> [JSON] { return level[JSONKey.lessons.keyValue()].arrayValue }
    
    static func Vocabulary(forLesson lesson:JSON)->[JSON] { return lesson[JSONKey.vocabularyCards.keyValue()].arrayValue }
    
    static func Grammar(forLesson lesson:JSON)->[JSON] { return lesson[JSONKey.grammarCards.keyValue()].arrayValue }
    


}
