//
//  Pitch.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

struct Pitch {
    var step: Step
    var octave: Int
    
    init(step: Step, octave: Int) {
        self.step = step
        self.octave = octave
    }
}
