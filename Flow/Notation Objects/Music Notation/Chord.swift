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
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType = .quarter,
         measure: Measure? = nil, 
         notes: [Note] = []) {
        self.notes = notes
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure)
        
        setImage()
    }
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType = .quarter,
         measure: Measure? = nil,
         note: Note) {
        self.notes = []
        notes.append(note)
        super.init(screenCoordinates: screenCoordinates, type: type, measure: measure)
        
        setImage()
    }
 
    override func setImage() {
        self.image = type.getNoteImage(isUpwards: true)
    }
    
    override func duplicate() -> Chord {
        //return super.duplicate()
        let chord = Chord(type: self.type, measure: self.measure)
        
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
            
            if self.notes.count < 2 && self.notes.count > 0 {
                //self.notes[0].measure = self.measure
                self.notes[0].chord = nil
                
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
