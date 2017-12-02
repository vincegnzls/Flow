//
//  Note.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Note: MusicNotation {
    
    struct Pitch {
        var step: String
        var octave: Int
        
        init(step: String, octave: Int) {
            self.step = step
            self.octave = octave
        }
    }
    
    // MARK: Properties
    var pitch: Pitch
    var type: RestNoteType
    
    init(screenCoordinates: ScreenCoordinates?,
         gridCoordinates: GridCoordinates?,
         pitch: Pitch,
         type: RestNoteType) {
        self.pitch = pitch
        self.type = type
        super.init(screenCoordinates: screenCoordinates, gridCoordinates: gridCoordinates)
        
        self.setImage()
    }
    
    private func setImage() {
        switch self.type {
        case .sixtyFourth:
            print("sixty fourth note")
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
