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

    init(){
        self.step = .C
        self.octave = 0
    }
    
    init(step: Step, octave: Int) {
        self.step = step
        self.octave = octave
    }

    public var hashValue: Int {
        return step.hashValue ^ octave.hashValue
    }

    public static func > (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.toValue() > rhs.toValue()
    }
    
    public static func < (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.toValue() < rhs.toValue()
    }
    
    public static func == (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.octave == rhs.octave &&
                lhs.step.toString() == rhs.step.toString()
    }
    
    public static func difference (from: Pitch, to: Pitch) -> Int {
        return ((from.octave - to.octave) * 7) + (from.step.toValue() - to.step.toValue())
    }
    
    public func toValue() -> Int {
        return self.octave * 7 + self.step.toValue()
    }

    mutating func transposeUp() {
        if self.step == .C {
            self.step = .D
        } else if self.step == .D {
            self.step = .E
        } else if self.step == .E {
            self.step = .F
        } else if self.step == .F {
            self.step = .G
        } else if self.step == .G {
            self.step = .A
        } else if self.step == .A {
            self.step = .B
        } else if self.step == .B {
            self.step = .C
            self.octave = self.octave + 1
        }
        print(self.step.toString())
    }
    
    mutating func transposeDown() {
        if self.step == .C {
            self.step = .B
            self.octave = self.octave - 1
        } else if self.step == .D {
            self.step = .C
        } else if self.step == .E {
            self.step = .D
        } else if self.step == .F {
            self.step = .E
        } else if self.step == .G {
            self.step = .F
        } else if self.step == .A {
            self.step = .G
        } else if self.step == .B {
            self.step = .A
        }
    }
}
