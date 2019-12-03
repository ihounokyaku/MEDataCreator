//
//  CustomTextCell.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 11/10/19.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

enum ColumnType: CaseIterable {
    case question
    case answer
    case notes
    
    func stringValue()->String {
        
        switch self {
            
        case .question:
            return JSONKey.question.keyValue()
            
        case .answer:
            return JSONKey.answer.keyValue()
            
        case .notes:
            return JSONKey.notes.keyValue()
            
        }
        
    }
    
}

class CustomTextCell: NSTextFieldCell {

    
    var column:ColumnType = .question
    var cardType:CardType = .vocab
    
    @IBInspectable
    var vocab:Bool {
        
        get { return self.cardType == .vocab }
        set {self.cardType = newValue ? .vocab : .grammar}
        
    }
    
    @IBInspectable
    var columnNumber:Int {
        
        get { return ColumnType.allCases.firstIndex(of: self.column)!}
        set {
            var index = min(newValue, ColumnType.allCases.count) - 1
            if index < 0 { index = 0 }
            
            self.column = ColumnType.allCases[index]
            
        }
        
        
    }
    
    
}
