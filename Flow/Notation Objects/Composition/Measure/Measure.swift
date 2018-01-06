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
    var clef: Clef
    var notationObjects: [MusicNotation]
    var bounds: Bounds
    var curBeatValue: Float
    var validNotes: [MusicNotation]
    
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
        self.validNotes = [MusicNotation]()
        
        initValidNotes()
    }
    
    public func addNoteInMeasure (_ musicNotation: MusicNotation) {
        
        print("ADD NOTE")
        
        if(isAddNoteValid(musicNotation: musicNotation)) {
            print("ADD NOTE VALID")
        
            self.curBeatValue += musicNotation.type.getBeatValue()
            notationObjects.append(musicNotation)
            
            updateValidNotes(validNotes: getValidNotes()) // update valid notes in notation controls after adding note
            
        } else {
            
            print("INVALID ADD NOTE")
            
        }
        
    }
    
    public func initValidNotes() {
        self.validNotes.append(MusicNotation(type: RestNoteType.whole))
        self.validNotes.append(MusicNotation(type: RestNoteType.half))
        self.validNotes.append(MusicNotation(type: RestNoteType.quarter))
        self.validNotes.append(MusicNotation(type: RestNoteType.eighth))
        self.validNotes.append(MusicNotation(type: RestNoteType.sixteenth))
        self.validNotes.append(MusicNotation(type: RestNoteType.thirtySecond))
        self.validNotes.append(MusicNotation(type: RestNoteType.sixtyFourth))
    }
    
    public func getValidNotes() -> [MusicNotation] {
        
        if RestNoteType.whole.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
            validNotes[0].valid = false
        } else {
            validNotes[0].valid = true
        }
        if RestNoteType.half.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
             validNotes[1].valid = false
        } else {
            validNotes[1].valid = true
        }
        if RestNoteType.quarter.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
            validNotes[2].valid = false
        } else {
            validNotes[2].valid = true
        }
        if RestNoteType.eighth.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
            validNotes[3].valid = false
        } else {
            validNotes[3].valid = false
        }
        if RestNoteType.sixteenth.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
            validNotes[4].valid = false
        } else {
            validNotes[4].valid = true
        }
        if RestNoteType.thirtySecond.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
            validNotes[5].valid = false
        } else {
            validNotes[5].valid = true
        }
        if RestNoteType.sixtyFourth.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
            validNotes[6].valid = false
        } else {
            validNotes[6].valid = true
        }
        
        return validNotes
    }
    
    // send event to notation controls
    public func updateValidNotes(validNotes: [MusicNotation]) {
        
        let params = Parameters()
        
        params.put(key: KeyNames.VALID_NOTES, value: validNotes)
        EventBroadcaster.instance.postEvent(event: EventNames.UPDATE_VALID_NOTES, params: params)
        
    }
    
    public func isAddNoteValid (musicNotation: MusicNotation) -> Bool {
        
        return self.curBeatValue + musicNotation.type.getBeatValue() <= self.timeSignature.getMaxBeatValue()
            
    }
    
    
}
