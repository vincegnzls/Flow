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
    var indices: [Int]
    
    init(notations: [MusicNotation]) {
        self.measures = []
        self.notations = notations
        self.indices = []
    }

    func execute() {
        for notation in self.notations {
            if let measure = notation.measure {
                self.indices.append(measure.notationObjects.index(of: notation)!)
                measure.remove(notation)
                self.measures.append(measure)
            }
        }
        UndoRedoManager.instance.addActionToUndoStack(self)
    }
    
    func undo() {
        print("Number of measures: \(self.measures.count)")
        print("Number of notation: \(self.notations.count)")
        print("Number of indices: \(self.indices.count)")
        for (i, measure) in self.measures.enumerated() {
            let notation = self.notations[i]
            let index = self.indices[i]
            measure.insert(notation, at: index)
        }
    }
    
    func redo() {
        for notation in self.notations {
            if let measure = notation.measure {
                measure.remove(notation)
            }
        }
    }
    
}
