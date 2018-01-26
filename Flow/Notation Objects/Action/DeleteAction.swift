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
        
        for (note, measure) in zip(notes, measures) {
            measure.deleteNoteInMeasure(note)
        }
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
