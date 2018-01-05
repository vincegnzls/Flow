//
//  AddAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class AddAction: Action {

    private var measure:Measure?
    private var note:MusicNotation?

    func execute() {
        measure!.addNoteInMeasure(musicNotation: note!)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }

    func setMeasure(measure:Measure) {
        self.measure = measure
    }

    func setNote(note:MusicNotation) {
        self.note = note
    }
    
    
}
