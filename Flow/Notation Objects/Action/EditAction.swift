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
    var oldNotations:[MusicNotation]
    var newNotations:MusicNotation
    
    init(measures: [Measure], oldNotations: [MusicNotation], newNotations: MusicNotation) {
        self.measures = measures
        self.oldNotations = oldNotations
        self.newNotations = newNotations
    }
    
    func execute() {
        
        for (notation, measure) in zip(oldNotations, measures) {
            measure.deleteInMeasure(notation)
        }
        
        measures[0].addToMeasure(newNotations)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
