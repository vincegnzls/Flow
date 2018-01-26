//
//  DeleteAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class DeleteAction: Action {
    
    var measures: [Measure]
    var notes:[MusicNotation]
    
    init(measures: [Measure], notes: [MusicNotation]) {
        self.measures = measures
        self.notes = notes
    }
    
    func execute() {
        
        var x = 0
        
        for note in self.notes {
            measures[x].deleteNoteInMeasure(note)
            x = x + 1
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
