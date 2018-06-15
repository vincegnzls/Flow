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
    var chord: Chord?
    var ottava: OttavaType?
    var connection: Connection?
    
    init(screenCoordinates: CGPoint? = nil,
         pitch: Pitch,
         type: RestNoteType,
         measure: Measure? = nil,
         accidental: Accidental? = nil,
         chord: Chord? = nil,
         dots: Int = 0,
         ottava: OttavaType? = nil,
         connection: Connection? = nil) {
        self.pitch = pitch
        self.accidental = accidental
        self.ottava = ottava
        self.connection = connection
        self.isUpwards = true
        self.beamed = false
        
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure, dots: dots)
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

        if let conn = self.connection {
            conn.updateType()
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

        if let conn = self.connection {
            conn.updateType()
        }
    }
    
    func convertOttavaPitch() -> Pitch? {
        if let ottava = self.ottava {
            if ottava == .eightVa {
                let newPitch = Pitch(step: self.pitch.step, octave: self.pitch.octave + 1)
                return newPitch
            } else if ottava == .eightVb {
                let newPitch = Pitch(step: self.pitch.step, octave: self.pitch.octave - 1)
                return newPitch
            } else if ottava == .fifteenMa {
                let newPitch = Pitch(step: self.pitch.step, octave: self.pitch.octave + 2)
                return newPitch
            } else  if ottava == .fifteenMb {
                let newPitch = Pitch(step: self.pitch.step, octave: self.pitch.octave - 2)
                return newPitch
            }
        }
        
        return nil
    }

    override func duplicate() -> Note {
        return Note(screenCoordinates: self.screenCoordinates, pitch: self.pitch, type: self.type, measure: self.measure, accidental: self.accidental, chord: self.chord, dots: self.dots, ottava: self.ottava, connection: self.connection)
    }
}
