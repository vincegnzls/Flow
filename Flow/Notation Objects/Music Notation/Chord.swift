//
//  Chord.swift
//  Flow
//
//  Created by Kevin Chan on 16/02/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class Chord: MusicNotation {
    
    var notes: [Note]
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType = .quarter,
         measure: Measure? = nil, 
         notes: [Note] = []) {
        self.notes = notes
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure)
    }
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType = .quarter,
         measure: Measure? = nil,
         note: Note) {
        self.notes = []
        notes.append(note)
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure)
    }
 
    override func setImage() {
        //self.image = type.getRestImage()
    }
    
    override func duplicate() -> Chord {
        //return super.duplicate()
        let chord = Chord()
        
        for note in notes {
            chord.notes.append(note.duplicate())
        }
        
        return chord
    }
}
