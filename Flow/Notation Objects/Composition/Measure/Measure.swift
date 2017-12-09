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
    
    init() {
        self.keySignature = .c
        self.timeSignature = TimeSignature()
        self.clef = .G
        self.notationObjects = []
    }
    
    init(keySignature: KeySignature, timeSignature: TimeSignature, clef: Clef) {
        self.keySignature = keySignature
        self.timeSignature = timeSignature
        self.clef = clef
        self.notationObjects = []
    }
}
