//
//  EditAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class EditAction: Action {
    
    var composition: Composition
    var oldNotes:[MusicNotation]
    var newNote:MusicNotation
    
    init(composition: Composition, oldNotes: [MusicNotation], newNote: MusicNotation) {
        self.composition = composition
        self.oldNotes = oldNotes
        self.newNote = newNote
    }
    
    func execute() {
        for oldNote in oldNotes {
            if let measure = composition.getMeasureOfNote(note: oldNote){
                measure.editNoteInMeasure(oldNote, newNote)
            }
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
