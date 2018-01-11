//
//  AddAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class AddAction: Action {

    var measure:Measure
    var note:MusicNotation
    
    init(measure: Measure, note: MusicNotation) {
        self.measure = measure
        self.note = note
    }

    func execute() {
        measure.addNoteInMeasure(note)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
