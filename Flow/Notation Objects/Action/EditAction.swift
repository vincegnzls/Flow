//
//  EditAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class EditAction: Action {
    
    var measures: [Measure]
    var oldNotes:[MusicNotation]
    var newNote:MusicNotation
    
    init(measures: [Measure], oldNotes: [MusicNotation], newNote: MusicNotation) {
        self.measures = measures
        self.oldNotes = oldNotes
        self.newNote = newNote
    }
    
    func execute() {
        
        for (oldNote, measure) in zip(oldNotes, measures) {
            measure.editNoteInMeasure(oldNote, newNote)
        }
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
