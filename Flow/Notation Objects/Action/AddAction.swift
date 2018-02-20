//
//  AddAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class AddAction: Action {

    var measures: [Measure]
    var notations: [MusicNotation]
    //var note:MusicNotation
    
    init(measure: Measure, notation: MusicNotation) {
        self.measures = []
        self.notations = []
        self.measures.append(measure)
        self.notations.append(notation)
    }

    init(measures: [Measure], notations: [MusicNotation]) {
        self.measures = measures
        self.notations = notations
    }

    func execute() {
        for (notation, measure) in zip(notations, measures) {
            measure.addToMeasure(notation)
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
