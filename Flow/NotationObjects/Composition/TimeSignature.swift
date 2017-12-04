//
//  TimeSignature.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

struct TimeSignature {
    var beats: Int // Top number
    var beatType: Int // Bottom number
    
    init() {
        self.beats = 4
        self.beatType = 4
    }
    
    init(beats: Int, beatType: Int) {
        self.beats = beats
        self.beatType = beatType
    }
}
