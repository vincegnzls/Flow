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
    
    init(beats: Int = 4, beatType: Int = 4) {
        self.beats = beats
        self.beatType = beatType
    }
    
    func getMaxBeatValue() -> Float {
        return Float(self.beats / self.beatType)
    }
}
