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
    private var timeSignatureEndIndex: Int
    private var keySignatureEndIndex: Int
    
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
        
        self.timeSignatureEndIndex = staves[0].measures.count
        self.keySignatureEndIndex = staves[0].measures.count
    }
    
    func execute() {
        // Change the time signature
        self.edit();
        UndoRedoManager.instance.addActionToUndoStack(self)
    }
    
    private func edit() {
        if self.oldKeySignature != self.newKeySignature {
            self.editKeySignature()
        }
        
        if self.oldTimeSignature != self.newTimeSignature {
            self.editTimeSignature()
        }
    }
    
    private func editTimeSignature() {
        var newNotations = [[MusicNotation]]()
        
        for staff in self.staves {
            // Create list of all the notations for each staff
            var notations = [MusicNotation]()
            
            
            var measureIndex = 0
            for measure in staff.measures {
                notations.append(contentsOf: measure.notationObjects)
                
                // Remove all notations from each measure
                // so we can add them back later while following the new time signature
                measure.removeAllNotations()
                if measure.timeSignature == oldTimeSignature {
                    
                    measure.timeSignature = newTimeSignature
                } else {
                    self.timeSignatureEndIndex = measureIndex
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
            
            newNotations.append(notations)
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
    }
    
    private func editKeySignature() {
        for staff in self.staves {
            for (index, measure) in staff.measures.enumerated() {
                if measure.keySignature == oldKeySignature {
                    measure.keySignature = newKeySignature
                } else {
                    self.keySignatureEndIndex = index
                    break
                }
            }
        }
    }
    
    private func undoEditTimeSignature() {
        var newNotations = [[MusicNotation]]()
        
        for staff in self.staves {
            // Create list of all the notations for each staff
            var notations = [MusicNotation]()
            
            
            var measureIndex = 0
            for measure in staff.measures {
                notations.append(contentsOf: measure.notationObjects)
                
                // Remove all notations from each measure
                // so we can add them back later while following the new time signature
                measure.removeAllNotations()
                if measure.timeSignature == newTimeSignature && measureIndex < timeSignatureEndIndex{
                    
                    measure.timeSignature = oldTimeSignature
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
            
            newNotations.append(notations)
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
    }
    
    private func undoEditKeySignature() {
        for staff in self.staves {
            for (index, measure) in staff.measures.enumerated() {
                if measure.keySignature == newKeySignature && index < self.keySignatureEndIndex{
                    measure.keySignature = oldKeySignature
                } else {
                    break
                }
            }
        }
    }
    
    func undo() {
        if self.oldKeySignature != self.newKeySignature {
            self.undoEditKeySignature()
        }
        
        if self.oldTimeSignature != self.newTimeSignature {
            self.undoEditTimeSignature()
        }
    }
    
    func redo() {
        self.edit()
    }
    
    
}
