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
    var pitch: Pitch {
        didSet {
            self.setImage()
        }
    }
    var accidental: Accidental? {
        didSet {
            self.setImage()
        }
    }
    var clef: Clef {
        didSet {
            self.setImage()
        }
    }
    var isUpwards: Bool
    
    init(screenCoordinates: CGPoint? = nil,
         gridCoordinates: GridCoordinates? = nil,
         pitch: Pitch,
         type: RestNoteType,
         accidental: Accidental? = nil,
         clef: Clef) {
        self.pitch = pitch
        self.accidental = accidental
        self.clef = clef
        self.isUpwards = false
        super.init(screenCoordinates: screenCoordinates, type: type)
    }
    
    // Set the image based on the note type and location in the staff
    override func setImage() {
        
        if clef == .G {
            isUpwards = pitch.octave < 5
        } else {
            isUpwards = pitch.octave < 2
        }
         
        self.image = type.getNoteImage(isUpwards: isUpwards)
    }
}
