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
    var staffIndex: Int
    
    init(screenCoordinates: ScreenCoordinates?,
         gridCoordinates: GridCoordinates?,
         pitch: Pitch,
         type: RestNoteType,
         accidental: Accidental?,
         staffIndex: Int) {
        self.pitch = pitch
        self.type = type
        self.accidental = accidental
        self.staffIndex = staffIndex
        super.init(screenCoordinates: screenCoordinates, gridCoordinates: gridCoordinates)
    }
    
    // Set the image based on the note type and location in the staff
    override func setImage() {
        switch self.type {
        case .sixtyFourth:
            if self.staffIndex > 12 {
                // Stem goes up
            }
            else {
                // Stem goes down 
            }
        case .thirtySecond:
            print("thirty second note")
        case.sixteenth:
            print("sixteenth note")
        case .eighth:
            print("eighth note")
        case .quarter:
            print("quarter note")
        case .half:
            print("half note")
        case .whole:
            print("whole note")
        }
    }
}
