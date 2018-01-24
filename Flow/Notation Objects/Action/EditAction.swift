//
//  EditAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class EditAction: Action {
    
    var measure:Measure
    var oldNote:MusicNotation
    var newNote:MusicNotation
    
    init(measure: Measure, oldNote: MusicNotation, newNote: MusicNotation) {
        self.measure = measure
        self.oldNote = oldNote
        self.newNote = newNote
    }
    
    func execute() {
        measure.editNoteInMeasure(oldNote, newNote)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
