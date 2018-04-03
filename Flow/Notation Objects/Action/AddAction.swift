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
        /*for (notation, measure) in zip(notations, measures) {
            measure.addToMeasure(notation)
        }*/
        
        for notation in self.notations {
            var measureIndex = 0
            
            if !self.measures[measureIndex].isAddNoteValid(musicNotation: notation.type) {
                measureIndex += 1
            }
            
            if measureIndex >= self.measures.count {
                break
            }
            
            let measure = measures[measureIndex]
            
            measure.addToMeasure(notation)
        }
        
        EventBroadcaster.instance.postEvent(event: EventNames.CHANGES_MADE)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
