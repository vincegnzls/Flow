//
//  Chord.swift
//  Flow
//
//  Created by Kevin Chan on 16/02/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class Chord: MusicNotation {
    
    var notes: [Note]

    var ottava: OttavaType? {
        didSet {
            for note in self.notes {
                note.ottava = ottava
            }
        }
    }
    
    override var dots: Int {
        didSet {
            for note in notes {
                note.dots = dots
            }
        }
    }
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType = .quarter,
         measure: Measure? = nil, 
         notes: [Note] = [],
         dots: Int = 0) {
        self.notes = notes
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure, dots: dots)
        
        setImage()
    }
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType = .quarter,
         measure: Measure? = nil,
         note: Note,
         dots: Int = 0) {
        self.notes = []
        notes.append(note)
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure, dots: dots)
        
        setImage()
    }
 
    override func setImage() {
        
        if self.type == .half {
            self.image = UIImage(named:"half-head")
        } else if self.type == .whole {
            self.image = UIImage(named:"whole-head")
        } else {
            self.image = UIImage(named:"quarter-head")
        }
        
    }
    
    override func duplicate() -> Chord {
        //return super.duplicate()
        let chord = Chord(type: self.type, measure: self.measure, dots: self.dots)
        
        for note in notes {
            let duplicatedNote = note.duplicate()
            duplicatedNote.chord = chord
            
            chord.notes.append(duplicatedNote)
        }
        
        return chord
    }
    
    public func removeNote (note: Note) { // ALWAYS USE THIS WHEN REMOVING NOTES FROM CHORDS
        if let index = self.notes.index(of: note) {
            self.notes.remove(at: index)
            
            if self.notes.count < 2 && self.notes.count > 0 { // only one left
                //self.notes[0].measure = self.measure
                self.notes[0].chord = nil
                
                self.notes[0].setImage()
                
                if let chordIndex = measure?.notationObjects.index(of: self) {
                    measure?.notationObjects.remove(at: chordIndex)
                    measure?.notationObjects.insert(self.notes[0], at: chordIndex)
                }
            }
        }
    }
    
    public func sortNotes () {
        
        notes = insertionSort(notes) {$0.pitch < $1.pitch}
        
        for note in notes {
            print ("NOTE : \(note.pitch)")
        }
        
    }
    
    public static func isSeventh(notes: [Note]) -> Bool {
        if notes.count > 3 {
            
            var minDiff = -1
            var maxDiff = 0
            
            for note in notes.reversed() {
                for innerNote in notes.reversed() {
                    
                    if note == innerNote {
                        continue
                    }
                    
                    var diff = Pitch.difference(from: note.pitch, to: innerNote.pitch)
                    
                    if diff < 0 {
                        diff = diff * -1
                    }
                    
                    if diff < minDiff || minDiff < 0 {
                        minDiff = diff
                    }
                    
                    if diff > maxDiff {
                        maxDiff = diff
                    }
                    
                }
            }
            
            if minDiff == 2 && maxDiff > 5 {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    public func isSeventh() -> Bool {
        if self.notes.count > 3 {
            
            var minDiff = -1
            var maxDiff = 0
            
            for note in self.notes.reversed() {
                for innerNote in self.notes.reversed() {
                    
                    if note == innerNote {
                        continue
                    }
                    
                    var diff = Pitch.difference(from: note.pitch, to: innerNote.pitch)
                    
                    if diff < 0 {
                        diff = diff * -1
                    }
                    
                    if diff < minDiff || minDiff < 0 {
                        minDiff = diff
                    }
                    
                    if diff > maxDiff {
                        maxDiff = diff
                    }
                    
                }
            }
            
            if minDiff == 2 && maxDiff > 5 {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    // INSERTION SORT FROM https://github.com/raywenderlich/swift-algorithm-club/tree/master/Insertion%20Sort
    // by raywenderlich : https://github.com/raywenderlich
    func insertionSort<T>(_ array: [T], _ isOrderedBefore: (T, T) -> Bool) -> [T] {
        guard array.count > 1 else { return array }
        
        var a = array
        for x in 1..<a.count {
            var y = x
            let temp = a[y]
            while y > 0 && isOrderedBefore(temp, a[y - 1]) {
                a[y] = a[y - 1]
                y -= 1
            }
            a[y] = temp
        }
        return a
    }
    
}
