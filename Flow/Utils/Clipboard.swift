//
//  Clipboard.swift
//  Flow
//
//  Created by Kevin Chan on 21/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Clipboard {
    
    // MARK: Shared instance
    static let instance = Clipboard()
    
    // MARK: Properties
    private var items: [MusicNotation]
    
    private init() {
        items = []
    }

    func cut(_ notations: [MusicNotation]) {
        self.items = notations
        /*for notation in notations {
            if let measure = notation.measure {
                measure.deleteInMeasure(notation)
                notation.measure = nil
            }
        }*/

        let deleteAction = DeleteAction(notations: notations)
        deleteAction.execute()
    }

    func copy(_ notations: [MusicNotation]) {
        self.items.removeAll()
        for notation in notations {
            let newNotation = notation.duplicate()
            newNotation.measure = nil
            self.items.append(newNotation)
        }
    }

    func paste(measures: [Measure], at startIndex: Int) {

        var noteIndex = startIndex
        var measureIndex = 0
        var oldNotations = [MusicNotation]()
        var newNotations = [MusicNotation]()

        for item in self.items {
            if noteIndex < measures[measureIndex].notationObjects.count {
                if !measures[measureIndex].isEditNoteValid(
                    oldNotations: [measures[measureIndex].notationObjects[noteIndex].type], newNotations: [item.type]) {
                    measureIndex += 1
                    noteIndex = 0
                }
            }

            if measureIndex >= measures.count {
                break
            }

            let measure = measures[measureIndex]
            
            if noteIndex < measure.notationObjects.count {
                let oldNotation = measure.notationObjects[noteIndex]
                
                oldNotations.append(oldNotation)
            }

            newNotations.append(item.duplicate())
            
            noteIndex += 1
        }
        
        if oldNotations.count > 0 {
            let editAction = EditAction(old: oldNotations, new: newNotations)
            editAction.execute()
        } else {
            let addAction = AddAction(measures: measures, notations: newNotations)
            addAction.execute()
        }

        
    }
}
