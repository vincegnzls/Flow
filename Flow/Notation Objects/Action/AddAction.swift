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
    var notations: [MusicNotation]
    //var note:MusicNotation
    
    init(measure: Measure, notation: MusicNotation) {
        self.measure = measure
        self.notations = []
        self.notations.append(notation)
    }

    init(measure: Measure, notations: [MusicNotation]) {
        self.measure = measure
        self.notations = notations
    }

    func execute() {
        for notation in notations {
            self.measure.addToMeasure(notation)
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
