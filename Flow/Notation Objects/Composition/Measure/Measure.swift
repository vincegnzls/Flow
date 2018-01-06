//
//  Measure.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Measure {
    var keySignature: KeySignature
    var timeSignature: TimeSignature
    var clef: Clef
    var notationObjects: [MusicNotation]
    var bounds: Bounds
    var curBeatValue: Float
    
    init(keySignature: KeySignature = .c,
         timeSignature: TimeSignature = TimeSignature(),
         clef: Clef = .G,
         notationObjects: [MusicNotation] = []) {
        self.keySignature = keySignature
        self.timeSignature = timeSignature
        self.clef = clef
        self.notationObjects = notationObjects
        self.bounds = Bounds()
        self.curBeatValue = 0
    }
    
    public func addNoteInMeasure (_ musicNotation: MusicNotation) {
        
        if(isAddNoteValid(musicNotation: musicNotation)) {
            
            self.curBeatValue += musicNotation.type.getBeatValue()
            notationObjects.append(musicNotation)
            
        } else {
            
            print("INVALID ADD NOTE")
            
        }
        
    }
    
    public func isAddNoteValid (musicNotation: MusicNotation) -> Bool {
        
        return self.curBeatValue <= self.timeSignature.getMaxBeatValue()
            
    }
}
