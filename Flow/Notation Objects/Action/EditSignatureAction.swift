//
//  EditSignatureAction.swift
//  Flow
//
//  Created by Kevin Chan on 25/04/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation

class EditSignatureAction: Action {
    
    var staves: [Staff]
    var oldKeySignature: KeySignature
    var oldTimeSignature: TimeSignature
    var newKeySignature: KeySignature
    var newTimeSignature: TimeSignature
    
    init(staves: [Staff],
         oldKeySignature: KeySignature,
         newKeySignature: KeySignature? = nil,
         oldTimeSignature: TimeSignature,
         newTimeSignature: TimeSignature? = nil) {
        self.staves = staves
        self.oldKeySignature = oldKeySignature
        self.oldTimeSignature = oldTimeSignature
        if let new = newKeySignature {
            self.newKeySignature = new
        } else {
            self.newKeySignature = oldKeySignature
        }
        
        if let new = newTimeSignature {
            self.newTimeSignature = new
        } else {
            self.newTimeSignature = oldTimeSignature
        }
        
    }
    
    func execute() {
        // Change the time signature
        
        if self.oldKeySignature != self.newKeySignature {
            self.editKeySignature()
        }
        
        if self.oldTimeSignature != self.newTimeSignature {
            self.editTimeSignature()
        }
    }
    
    private func editTimeSignature() {
        let newMaxBeatValue: Float = self.newTimeSignature.getMaxBeatValue()
        var newNotations = [[MusicNotation]]()
        
        for staff in self.staves {
            // Create list of all the notations for each staff
            var notations = [MusicNotation]()
            newNotations.append(notations)
            
            var measureIndex = 0
            for measure in staff.measures {
                notations.append(contentsOf: measure.notationObjects)
                
                // Remove all notations from each measure
                // so we can add them back later while following the new time signature
                measure.removeAllNotations()
                if measure.timeSignature == oldTimeSignature {
                    
                    measure.timeSignature = newTimeSignature
                } else {
                    break
                }
                
                measureIndex += 1
            }
            
            for measure in staff.measures[measureIndex...] {
                notations.append(contentsOf: measure.notationObjects)
                
                // Remove all notations from each measure
                // so we can add them back later while following the new time signature
                measure.removeAllNotations()
            }
        }
    
        var index = 0
        for (staff, notations) in zip(self.staves, newNotations) {
            for measure in staff.measures {
                while index < notations.count && measure.add(notations[index]) {
                    index += 1
                }
                
                measure.fillWithRests()
            }
        }
        
//        moveCursorsToNearestSnapPoint(location: sheetCursor.curYCursorLocation)
    }
    
    public func editKeySignature() {
        for staff in self.staves {
            for measure in staff.measures {
                if measure.keySignature == oldKeySignature {
                    measure.keySignature = newKeySignature
                } else {
                    break
                }
            }
        }
    }
    
    func undo() {
        // Code here
    }
    
    func redo() {
        // Code here
    }
    
    
}
