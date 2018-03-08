//
//  TimeSignature.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

struct TimeSignature: Equatable {
    var beats: Int // Top number
    var beatType: Int // Bottom number
    
    init(beats: Int = 4, beatType: Int = 4) {
        self.beats = beats
        self.beatType = beatType
    }
    
    func getMaxBeatValue() -> Float {
        return Float(Float(self.beats) / Float(self.beatType))
    }

    func getMaxBeatValuePerGroup() -> Float {
        return Float(Float(1) / Float(self.beatType))
    }
    
    public var hashValue: Int {
        return beats.hashValue ^ beatType.hashValue
    }
    
    public static func == (lhs: TimeSignature, rhs: TimeSignature) -> Bool {
        return lhs.beatType == rhs.beatType &&
            lhs.beats == rhs.beats
    }
    
    public static func != (lhs: TimeSignature, rhs: TimeSignature) -> Bool {
        return lhs.beatType != rhs.beatType &&
            lhs.beats != rhs.beats
    }
}
