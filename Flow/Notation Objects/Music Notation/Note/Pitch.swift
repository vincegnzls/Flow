//
//  Pitch.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

struct Pitch : Hashable {
    var step: Step
    var octave: Int
    
    init(step: Step, octave: Int) {
        self.step = step
        self.octave = octave
    }

    public var hashValue: Int {
        return step.hashValue ^ octave.hashValue
    }

    public static func == (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.octave == rhs.octave &&
                lhs.step.toString() == rhs.step.toString()
    }

}
