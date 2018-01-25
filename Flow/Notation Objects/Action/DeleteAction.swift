//
//  DeleteAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class DeleteAction: Action {
    
    var composition: Composition
    var notes:[MusicNotation]
    
    init(composition: Composition, notes: [MusicNotation]) {
        self.composition = composition
        self.notes = notes
    }
    
    func execute() {
        
        for note in self.notes {
            if let measure = self.composition.getMeasureOfNote(note: note) {
                measure.deleteNoteInMeasure(note)
            }
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
