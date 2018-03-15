//
//  Measure.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Measure: Equatable {

    var keySignature: KeySignature {
        didSet {
            updateKeySignature()
        }
    }
    var timeSignature: TimeSignature
    var clef: Clef
    var notationObjects: [MusicNotation] {
        didSet{
            print("TOTAL BEATS: \(getTotalBeats())")
            print("MAX BEATS: \(timeSignature.getMaxBeatValue())")
            curBeatValue = getTotalBeats()
            print("INVALID NOTES: \(getInvalidNotes())")
            updateInvalidNotes(invalidNotes: getInvalidNotes()) // update valid notes in notation controls
            updateGroups()
            updateKeySignature()
        }
    }
    var bounds: Bounds
    var curBeatValue: Float
    var validNotes: [RestNoteType]
    var groups: [[MusicNotation]]

    var isFull: Bool {
        return self.curBeatValue == self.timeSignature.getMaxBeatValue()
    }
    
    var divisions: Int {
        var divisions = 1
        for notation in self.notationObjects {
            divisions = max(notation.type.getDivision(), divisions)
        }
        
        return divisions
    }
    
    init(keySignature: KeySignature = .c,
         timeSignature: TimeSignature = TimeSignature(),
         clef: Clef = .G,
         notationObjects: [MusicNotation] = [], loading: Bool?) {
        self.keySignature = keySignature
        self.timeSignature = timeSignature
        self.clef = clef
        self.notationObjects = notationObjects
        self.bounds = Bounds()
        self.curBeatValue = 0
        self.validNotes = [RestNoteType]()
        self.groups = [[MusicNotation]]()
        if let isLoading = loading {
            if !isLoading {
                self.fillWithRests()
                //self.fillWithRests()
            }
        }

        updateKeySignature()
    }

    // Equatable operators
    static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs === rhs
    }

    static func != (lhs: Measure, rhs: Measure) -> Bool {
        return lhs !== rhs
    }

    public func addToMeasure(_ notation: MusicNotation) {
        if(isAddNoteValid(musicNotation: notation.type)) {
            print("ADD NOTE VALID")

            notation.measure = self
            notationObjects.append(notation)
            //self.fillWithRests()
        } else {

            print("INVALID ADD NOTE")

        }
    }
    
    public func addToMeasure(_ notation: MusicNotation, at index: Int) {
        if(isAddNoteValid(musicNotation: notation.type)) {
            print("ADD NOTE VALID")
            
            notation.measure = self
            print("inserting note at index \(index)")
            print("before inserting: ")
            for notation in notationObjects {
                print(notation.type.toString())
            }
            self.notationObjects.insert(notation, at: index)
            //self.fillWithRests()
            print("after inserting:")
            for notation in notationObjects {
                print(notation.type.toString())
            }
        } else {
            
            print("INVALID ADD NOTE")
            
        }
    }

    public func deleteInMeasure(_ musicNotation: MusicNotation) {

        if let index = notationObjects.index(of: musicNotation) {
            musicNotation.measure = nil
            notationObjects.remove(at: index)
            //self.fillWithRests()
        }

    }

    public func editInMeasure(_ oldNote: MusicNotation, _ newNote: MusicNotation) {
        print("EDIT")
        if let index = notationObjects.index(of: oldNote) {
            oldNote.measure = nil
            notationObjects[index] = newNote
            newNote.measure = self
            //self.fillWithRests()
        }
    }

    public func getInvalidNotes() -> [RestNoteType] {
        
//        print("CUR BEAT VALUE: " + String(curBeatValue))
//        print("MAX BEAT VALUE: " + String(timeSignature.getMaxBeatValue()))
        
        var invalidNotes = [RestNoteType]()

        for note in RestNoteType.types {
            if note.getBeatValue() + curBeatValue > timeSignature.getMaxBeatValue() {
                invalidNotes.append(note)
            }
        }

        return invalidNotes

    }
    
    public func getInvalidNotes(without filteredNotation: MusicNotation) -> [RestNoteType] {
        var invalidNotes = [RestNoteType]()
        
        let beatValue = self.curBeatValue - filteredNotation.type.getBeatValue()
        
        for note in RestNoteType.types {

            if note.getBeatValue() + beatValue > timeSignature.getMaxBeatValue() {
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

        print("NOTES: \(notationObjects)")

        return totalBeats
    }

    public func containsRest() -> Bool {
        for note in notationObjects {
            if let _ = note as? Rest {
                return true
            }
        }

        return false
    }

    func fillWithRests() {
        while getTotalBeats() < timeSignature.getMaxBeatValue() {
            for rest in RestNoteType.types {
                let curRest = Rest(type: rest)
                self.addToMeasure(curRest)
            }
        }
    }

    func updateGroups() {
        print("CALL UPDATE GROUP: \(notationObjects)")
        self.groups.removeAll()

        var curGroup = [MusicNotation]()

        for note in notationObjects {
            if !groupFull(group: curGroup, isEighth: note.type == .eighth) {
                curGroup.append(note)
            } else {
                self.groups.append(curGroup)
                curGroup.removeAll()
                curGroup.append(note)
            }
        }

        self.groups.append(curGroup)

        /*var x = 0

        if self.groups.count > 1 {
            var curMerge = [[MusicNotation]]()

            for group in self.groups {
                if isPureEighth(group: group) && curMerge.count < 2 {
                    curMerge.append(group)
                } else if isPureEighth(group: group) && curMerge.count == 2 {
                    //insert merge here


                }

                x = x + 1
            }
        }*/
    }

    func getIndexOfGroup(group: [MusicNotation]) -> Int {
        var x = 0

        for g in groups {
            if g.elementsEqual(group) {
                return x
            }
        }

        return -1
    }

    func isPureEighth(group: [MusicNotation]) -> Bool {
        for note in group {
            if note.type != .eighth {
                return false
            }
        }

        return true
    }

    func groupFull(group: [MusicNotation], isEighth: Bool) -> Bool {
        var curBeatValue: Float = 0

        for note in group {
            curBeatValue = note.type.getBeatValue() + curBeatValue
        }

        /*if timeSignature.beatType == 4 && timeSignature.beats == 4 {
            if isPureEighth(group: group) {
                if isEighth {
                    if curBeatValue < timeSignature.getMaxBeatValuePerGroup() * 2 {
                        return false
                    }
                }
            }
        }*/

        if curBeatValue < timeSignature.getMaxBeatValuePerGroup() {
            return false
        }

        return true
    }

    func updateKeySignature() {
        switch(self.keySignature) {
            case .c:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        if let _ = note.accidental {
                            note.accidental = nil
                        }
                    }
                }
                break
            case .f:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .bFlat:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B || notePitch == .E {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .eFlat:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B || notePitch == .E || notePitch == .A {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .aFlat:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .dFlat:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .gFlat:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G || notePitch == .C {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .cFlat:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G || notePitch == .C || notePitch == .F {
                            note.accidental = .flat
                        }
                    }
                }
                break
            case .g:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F {
                            note.accidental = .sharp
                        }
                    }
                }
                break
            case .d:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F || notePitch == .C {
                            note.accidental = .sharp
                        }
                    }
                }
                break
            case .a:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F || notePitch == .C || notePitch == .G {
                            note.accidental = .sharp
                        }
                    }
                }
                break
            case .e:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D {
                            note.accidental = .sharp
                        }
                    }
                }
                break
            case .b:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A {
                            note.accidental = .sharp
                        }
                    }
                }
                break
            case .fSharp:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A || notePitch == .E {
                            note.accidental = .sharp
                        }
                    }
                }
                break
            case .cSharp:
                for notation in self.notationObjects {
                    if let note = notation as? Note {
                        let notePitch = note.pitch.step

                        if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A || notePitch == .E || notePitch == .B {
                            note.accidental = .sharp
                        }
                    }
                }
                break
        }
    }
}
