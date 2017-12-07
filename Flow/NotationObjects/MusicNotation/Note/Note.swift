//
//  Note.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Note: MusicNotation {
    // MARK: Properties
    var pitch: Pitch
    var type: RestNoteType
    var accidental: Accidental?
    var clef: Clef
    
    init(pitch: Pitch,
         type: RestNoteType,
         clef: Clef) {
        self.pitch = pitch
        self.type = type
        self.clef = clef
        super.init()
    }
    
    init(pitch: Pitch,
         type: RestNoteType,
         accidental: Accidental?,
         clef: Clef) {
        self.pitch = pitch
        self.type = type
        self.accidental = accidental
        self.clef = clef
        super.init()
    }
    
    init(screenCoordinates: ScreenCoordinates?,
         gridCoordinates: GridCoordinates?,
         pitch: Pitch,
         type: RestNoteType,
         accidental: Accidental?,
         clef: Clef) {
        self.pitch = pitch
        self.type = type
        self.accidental = accidental
        self.clef = clef
        super.init(screenCoordinates: screenCoordinates, gridCoordinates: gridCoordinates)
    }
    
    // Set the image based on the note type and location in the staff
    override func setImage() {
        var isUpwards: Bool
        
        if clef == .G {
            isUpwards = pitch.octave < 5
        }
        else {
            isUpwards = pitch.octave < 2
        }
         
        self.image = type.getNoteImage(isUpwards: isUpwards)
    }
}
