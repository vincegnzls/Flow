//
//  Measure.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Measure: Hashable {

    var keySignature: KeySignature {
        didSet {
            //updateKeySignature()
        }
    }
    var timeSignature: TimeSignature
    var clef: Clef
    var notationObjects: [MusicNotation] {
        didSet{
            curBeatValue = getTotalBeats()
            updateInvalidNotes(invalidNotes: getInvalidNotes()) // update valid notes in notation controls
            updateGroups()
            //updateKeySignature()
        }
    }
    var bounds: Bounds
    var curBeatValue: Float
    var validNotes: [RestNoteType]
    var groups: [[MusicNotation]]

    var isFull: Bool {
        return self.curBeatValue == self.timeSignature.getMaxBeatValue()
    }

    var isFullWithNotes: Bool {
        for notation in self.notationObjects {
            if let _ = notation as? Rest {
                return false
            }
        }

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

        //updateKeySignature()
    }
    
    public var hashValue: Int {
        
        var hashValueForNotations = 0
        
        for notation in notationObjects {
            if let note = notation as? Note {
                hashValueForNotations ^= note.pitch.hashValue ^ note.type.hashValue
            } else if let rest = notation as? Rest {
                hashValueForNotations ^= rest.type.hashValue
            }
        }
        
        return keySignature.hashValue ^ timeSignature.hashValue ^ clef.hashValue ^ curBeatValue.hashValue ^ hashValueForNotations
        
    }

    // Equatable operators
    static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs === rhs
    }

    static func != (lhs: Measure, rhs: Measure) -> Bool {
        return lhs !== rhs
    }

    public func add(_ notation: MusicNotation) -> Bool {
        if(isAddNoteValid(musicNotation: notation.type)) {
            //CHECKING OF NOTE PITCH OUT OF BOUNDS
            if let note = notation as? Note {
                notationObjects.append(note)
                note.measure = self

                fixNoteOutOfBounds(note: note)
            } else {
                notationObjects.append(notation)
                notation.measure = self
            }

            if self.isFullWithNotes {
                let params = Parameters()
                params.put(key: KeyNames.ARROW_KEY_DIRECTION, value: ArrowKey.right)
                EventBroadcaster.instance.postEvent(event: EventNames.ARROW_KEY_PRESSED, params: params)
            }
            return  true
            //self.fillWithRests()
        } else {
            return false
        }
    }

    public func fixNoteOutOfBounds(note: Note) {
        if let noteMeasure = note.measure {
            if noteMeasure.clef == .G {
                if note.pitch.octave * 8 + note.pitch.step.rawValue > 51 {
                    while note.pitch.octave * 8 + note.pitch.step.rawValue > 51 {
                        note.pitch.octave -= 1
                    }
                } else if note.pitch.octave * 8 + note.pitch.step.rawValue < 26 {
                    while note.pitch.octave * 8 + note.pitch.step.rawValue < 26 {
                        note.pitch.octave += 1
                    }
                }
            } else if noteMeasure.clef == .F {
                if note.pitch.octave * 8 + note.pitch.step.rawValue < 12 {
                    while note.pitch.octave * 8 + note.pitch.step.rawValue < 12 {
                        note.pitch.octave += 1
                    }
                } else if note.pitch.octave * 8 + note.pitch.step.rawValue > 37 {
                    while note.pitch.octave * 8 + note.pitch.step.rawValue > 37 {
                        note.pitch.octave -= 1
                    }
                }
            }
        }
    }
    
    public func add(_ notation: MusicNotation, at index: Int) -> Bool {
        if(isAddNoteValid(musicNotation: notation.type)) {
            notation.measure = self

            //CHECKING OF NOTE PITCH OUT OF BOUNDS
            if let note = notation as? Note {
                self.notationObjects.insert(notation, at: index)
                note.measure = self

                fixNoteOutOfBounds(note: note)
            } else {
                self.notationObjects.insert(notation, at: index)
                notation.measure = self
            }

            if self.isFullWithNotes {
                let params = Parameters()
                params.put(key: KeyNames.ARROW_KEY_DIRECTION, value: ArrowKey.right)
                EventBroadcaster.instance.postEvent(event: EventNames.ARROW_KEY_PRESSED, params: params)
            }

            return  true
        } else {
            return false
        }
    }

    public func remove(_ musicNotation: MusicNotation) {

        if let index = notationObjects.index(of: musicNotation) {
            musicNotation.measure = nil
            notationObjects.remove(at: index)
            //self.fillWithRests()
        }

    }

    public func replace(_ oldNote: MusicNotation, _ newNote: MusicNotation) {
        if let index = notationObjects.index(of: oldNote) {
            oldNote.measure = nil

            //CHECKING OF NOTE PITCH OUT OF BOUNDS
            if let note = newNote as? Note {
                notationObjects[index] = note
                note.measure = self
                
                if let noteMeasure = note.measure {
                    if noteMeasure.clef == .G {
                        if note.pitch.octave * 8 + note.pitch.step.rawValue > 51 {
                            while note.pitch.octave * 8 + note.pitch.step.rawValue > 51 {
                                note.pitch.octave -= 1
                            }
                        } else if note.pitch.octave * 8 + note.pitch.step.rawValue < 26 {
                            while note.pitch.octave * 8 + note.pitch.step.rawValue < 26 {
                                note.pitch.octave += 1
                            }
                        }
                    } else if noteMeasure.clef == .F {
                        if note.pitch.octave * 8 + note.pitch.step.rawValue < 12 {
                            while note.pitch.octave * 8 + note.pitch.step.rawValue < 12 {
                                note.pitch.octave += 1
                            }
                        } else if note.pitch.octave * 8 + note.pitch.step.rawValue > 37 {
                            while note.pitch.octave * 8 + note.pitch.step.rawValue > 37 {
                                note.pitch.octave -= 1
                            }
                        }
                    }
                }
            } else {
                notationObjects[index] = newNote
                newNote.measure = self
            }
            //self.fillWithRests()
        }
    }

    public func getInvalidNotes() -> [RestNoteType] {
        
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
    
    public func isEditNoteValid (oldNotations: [RestNoteType], newNotations: [RestNoteType]) -> Bool {
        
        var oldBeats: Float = 0
        
        for oldType in oldNotations {
            oldBeats += oldType.getBeatValue()
        }
        
        var newBeats: Float = 0
        
        for newType in newNotations {
            newBeats += newType.getBeatValue()
        }
        
        return self.curBeatValue - oldBeats + newBeats <= self.timeSignature.getMaxBeatValue()
        
    }

    public func getTotalBeats() -> Float {

        var totalBeats: Float = 0

        for note in self.notationObjects {
            totalBeats = totalBeats + note.type.getBeatValue()
        }

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

    func fillWithRests(isAction: Bool = false) {
        var restsToAdd = [Rest]()
        var addedBeats:Float = 0
        let currentBeats = self.getTotalBeats()

        while currentBeats + addedBeats < timeSignature.getMaxBeatValue(){
            for type in RestNoteType.types {
                if self.isAddNoteValid(musicNotation: type) {
                    restsToAdd.append(Rest(type: type))
                    addedBeats += type.getBeatValue()
                    break;
                }
            }
        }
        
        if isAction && restsToAdd.isNotEmpty {
            let addAction = AddAction(measures: [self], notations: restsToAdd)
            addAction.execute()
        } else {
            for rest in restsToAdd {
                self.add(rest)
            }
        }
    }

    func updateGroups() {
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

    func removeAllNotations() {
        self.notationObjects.removeAll()
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
