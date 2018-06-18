//
//  MIDINoteParser.swift
//  Flow
//
//  Created by Vince on 06/05/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation
import UIKit
import AudioKitUI

class MIDINoteParser {
    static let instance = MIDINoteParser()
    
    func parse(noteNumber: MIDINoteNumber, type: RestNoteType) -> Note {

        var pitch = Pitch()
        var accidental: Accidental? = nil

        if noteNumber >= 0 && noteNumber <= 11 {
            pitch.octave = -1
        } else if noteNumber >= 12 && noteNumber <= 23 {
            pitch.octave = 0
        } else if noteNumber >= 24 && noteNumber <= 35 {
            pitch.octave = 1
        } else if noteNumber >= 36 && noteNumber <= 47 {
            pitch.octave = 2
        }else if noteNumber >= 48 && noteNumber <= 59 {
            pitch.octave = 3
        } else if noteNumber >= 60 && noteNumber <= 71 {
            pitch.octave = 4
        } else if noteNumber >= 72 && noteNumber <= 83 {
            pitch.octave = 5
        } else if noteNumber >= 84 && noteNumber <= 95 {
            pitch.octave = 6
        } else if noteNumber >= 96 && noteNumber <= 107 {
            pitch.octave = 7
        } else if noteNumber >= 108 && noteNumber <= 119 {
            pitch.octave = 8
        } else if noteNumber >= 120 && noteNumber <= 127 {
            pitch.octave = 9
        }

        if noteNumber % 12 == 0 || noteNumber % 12 == 1 {
            pitch.step = .C

            if noteNumber % 12 == 1 {
                accidental = .sharp
            }
        } else if noteNumber % 12 == 2 || noteNumber % 12 == 3 {
            pitch.step = .D

            if noteNumber % 12 == 3 {
                accidental = .sharp
            }
        } else if noteNumber % 12 == 4 {
            pitch.step = .E
        } else if noteNumber % 12 == 5 || noteNumber % 12 == 6 {
            pitch.step = .F

            if noteNumber % 12 == 6 {
                accidental = .sharp
            }
        } else if noteNumber % 12 == 7 || noteNumber % 12 == 8 {
            pitch.step = .G

            if noteNumber % 12 == 8 {
                accidental = .sharp
            }
        } else if noteNumber % 12 == 9 || noteNumber % 12 == 10 {
            pitch.step = .A

            if noteNumber % 12 == 10 {
                accidental = .sharp
            }
        } else if noteNumber % 12 == 11 {
            pitch.step = .B
        }
        
        print("PARSER: \(pitch.step)")

        return Note(pitch: pitch, type: type, accidental: accidental)
    }
}
