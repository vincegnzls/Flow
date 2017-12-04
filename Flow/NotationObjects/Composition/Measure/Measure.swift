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
    var notationObjects: Array<MusicNotation>
    
    init() {
        self.keySignature = .c
        self.timeSignature = TimeSignature()
        self.notationObjects = []
    }
    
    init(keySignature: KeySignature, timeSignature: TimeSignature) {
        self.keySignature = keySignature
        self.timeSignature = timeSignature
        self.notationObjects = []
    }
}
