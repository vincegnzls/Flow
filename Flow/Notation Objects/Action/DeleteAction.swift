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
    var notations:[MusicNotation]
    
    init(measures: [Measure], notations: [MusicNotation]) {
        self.measures = measures
        self.notations = notations
    }

    func execute() {
        
        for (note, measure) in zip(notations, measures) {
            measure.deleteInMeasure(note)
        }
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
