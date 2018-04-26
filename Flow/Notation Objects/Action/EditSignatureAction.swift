//
//  EditSignatureAction.swift
//  Flow
//
//  Created by Kevin Chan on 25/04/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation

class EditSignatureAction: Action {
    
    var measures: [Measure]
    var oldKeySignature: KeySignature
    var oldTimeSignature: TimeSignature
    var newKeySignature: KeySignature
    var newTimeSignature: TimeSignature
    
    init(measures: [Measure],
         oldKeySignature: KeySignature,
         newKeySignature: KeySignature? = nil,
         oldTimeSignature: TimeSignature,
         newTimeSignature: TimeSignature? = nil) {
        self.measures = measures
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
        // Code here
    }
    
    func undo() {
        // Code here
    }
    
    func redo() {
        // Code here
    }
    
    
}
