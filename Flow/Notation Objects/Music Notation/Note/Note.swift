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
    var isUpwards: Bool
    var beamed: Bool
    
    init(screenCoordinates: CGPoint? = nil,
         pitch: Pitch,
         type: RestNoteType,
         measure: Measure? = nil,
         accidental: Accidental? = nil) {
        self.pitch = pitch
        self.accidental = accidental
        self.isUpwards = true
        self.beamed = false
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure)
    }
    
    // Set the image based on the note type and location in the staff
    override func setImage() {

        print("PITCH NUMBER: \(pitch.octave * 8 + pitch.step.rawValue)")

        if let clef = self.measure?.clef {
            if clef == .G {
                isUpwards = pitch.octave * 8 + pitch.step.rawValue < 38
            } else {
                isUpwards = pitch.octave * 8 + pitch.step.rawValue < 25
            }
        }

        self.image = type.getNoteImage(isUpwards: isUpwards)
        
        /*if self.isSelected {
            if let imageView = self.imageView {
                imageView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            }
        }*/
    }
    
    func transposeUp() {
        if let clef = self.measure?.clef {
            if clef == .G {
                if pitch.octave * 8 + pitch.step.rawValue < 51 {
                    self.pitch.transposeUp()
                }
            } else {
                if pitch.octave * 8 + pitch.step.rawValue < 37 {
                    self.pitch.transposeUp()
                }
            }
        }
    }
    
    func transposeDown() {
        if let clef = self.measure?.clef {
            if clef == .G {
                if pitch.octave * 8 + pitch.step.rawValue > 26 {
                    self.pitch.transposeDown()
                }
            } else {
                if pitch.octave * 8 + pitch.step.rawValue > 12 {
                    self.pitch.transposeDown()
                }
            }
        }
    }

    override func duplicate() -> Note {
        return Note(screenCoordinates: self.screenCoordinates, pitch: self.pitch, type: self.type, measure: self.measure, accidental: self.accidental)
    }
}
