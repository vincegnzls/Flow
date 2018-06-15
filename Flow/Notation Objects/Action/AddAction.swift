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
        self.add()
        UndoRedoManager.instance.addActionToUndoStack(self)
    }
    
    private func add() {
        for notation in self.notations {
            var measureIndex = 0
            
            if !self.measures[measureIndex].isAddNoteValid(musicNotation: notation.type) {
                measureIndex += 1
            }
            
            if measureIndex >= self.measures.count {
                break
            }
            
            let measure = measures[measureIndex]
            
            measure.add(notation)
        }
    }
    
    func undo() {
        for notation in self.notations {
            notation.measure?.remove(notation)
        }
        
        let params = Parameters()
        params.put(key: KeyNames.ACTION_DONE, value: self)
        params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.UNDO)
        EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
    }
    
    func redo() {
        self.add()
        
        let params = Parameters()
        params.put(key: KeyNames.ACTION_DONE, value: self)
        params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.REDO)
        EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
    }
}
