//
//  Measure.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Measure: Equatable {

    var keySignature: KeySignature
    var timeSignature: TimeSignature
    var clef: Clef
    var notationObjects: [MusicNotation] {
        didSet{
            print("SAAAAAAAAAAA")
            curBeatValue = getTotalBeats()
            updateInvalidNotes(invalidNotes: getInvalidNotes()) // update valid notes in notation controls
        }
    }
    var bounds: Bounds
    var curBeatValue: Float
    var validNotes: [RestNoteType]

    var isFull: Bool {
        return self.curBeatValue == self.timeSignature.getMaxBeatValue()
    }
    
    init(keySignature: KeySignature = .c,
         timeSignature: TimeSignature = TimeSignature(),
         clef: Clef = .G,
         notationObjects: [MusicNotation] = []) {
        self.keySignature = keySignature
        self.timeSignature = timeSignature
        self.clef = clef
        self.notationObjects = notationObjects
        self.bounds = Bounds()
        self.curBeatValue = 0
        self.validNotes = [RestNoteType]()
    }

    // Equatable operators
    static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs === rhs
    }

    static func != (lhs: Measure, rhs: Measure) -> Bool {
        return lhs !== rhs
    }

    public func addToMeasure(_ musicNotation: MusicNotation) {

        print("ADD NOTE")

        if(isAddNoteValid(musicNotation: musicNotation.type)) {
            print("ADD NOTE VALID")

            musicNotation.measure = self
            notationObjects.append(musicNotation)

        } else {

            print("INVALID ADD NOTE")

        }

    }

    public func deleteInMeasure(_ musicNotation: MusicNotation) {

        if let index = notationObjects.index(where: {$0 === musicNotation}) {

            musicNotation.measure = nil
            notationObjects.remove(at: index)

        }

    }

    public func editInMeasure(_ oldNote: MusicNotation, _ newNote: MusicNotation) {

        if let index = notationObjects.index(where: {$0 === oldNote}) {

            notationObjects[index] = newNote

        }

    }

    public func getInvalidNotes() -> [RestNoteType] {
        
        print("CUR BEAT VALUE: " + String(curBeatValue))
        print("MAX BEAT VALUE: " + String(timeSignature.getMaxBeatValue()))
        
        var invalidNotes = [RestNoteType]()

        for note in RestNoteType.types {
            if note.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
                invalidNotes.append(note)
            }
        }

        return invalidNotes

    }

    // send event to notation controls
    public func updateInvalidNotes(invalidNotes: [RestNoteType]) {

        let params = Parameters()

        params.put(key: KeyNames.INVALID_NOTES, value: invalidNotes)
        EventBroadcaster.instance.postEvent(event: EventNames.UPDATE_INVALID_NOTES, params: params)

    }

    public func isAddNoteValid (musicNotation: RestNoteType) -> Bool {

        return self.curBeatValue + musicNotation.getBeatValue() <= self.timeSignature.getMaxBeatValue()

    }

    public func getTotalBeats() -> Float {

        var totalBeats: Float = 0

        for note in self.notationObjects {
            totalBeats = totalBeats + note.type.getBeatValue()
        }

        return totalBeats
    }
}
