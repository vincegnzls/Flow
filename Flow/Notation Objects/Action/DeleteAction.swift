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
    
    init(notations: [MusicNotation]) {
        self.measures = []
        self.notations = notations
    }

    func execute() {
        
        /*for (note, measure) in zip(notations, measures) {
            measure.deleteInMeasure(note)
        }*/
        for notation in self.notations {
            if let measure = notation.measure {
                measure.deleteInMeasure(notation)
                notation.measure = nil
                self.measures.append(measure)
            }
        }
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
