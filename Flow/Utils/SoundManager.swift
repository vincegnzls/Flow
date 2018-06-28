//
//  SoundManager.swift
//  Flow
//
//  Created by Kevin Chan on 03/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//
//

import Foundation
import AVFoundation
import AudioKit
import AudioKitUI

class SoundManager {

    static let instance = SoundManager()

    var tempo: Double
    var player = AVPlayer()
    var timer = Timer()
    var isPlaying: Bool
    
    var gNotesMIDI: [[Int?]]
    var fNotesMIDI: [[Int?]]
    
    var gNotesType: [[RestNoteType?]]
    var fNotesType: [[RestNoteType?]]
    
    var gNotesConnType: [[ConnectionType?]]
    var fNotesConnType: [[ConnectionType?]]
    
    var gNotes: [MusicNotation]
    var fNotes: [MusicNotation]

    var compMeasures: [Measure]
    
    var gNotePlayer: AKSampler
    var fNotePlayer: AKSampler
    
    var grandStaffMixerG: AKMixer
    var grandStaffMixerF: AKMixer
    
    var curBeat: Int
    
    init() {
        self.tempo = 120
        self.isPlaying = false
        self.gNotesMIDI = [[Int?]]()
        self.fNotesMIDI = [[Int?]]()
        self.gNotesType = [[RestNoteType?]]()
        self.fNotesType = [[RestNoteType?]]()
        self.gNotesConnType = [[ConnectionType?]]()
        self.fNotesConnType = [[ConnectionType?]]()
        self.gNotes = [MusicNotation]()
        self.fNotes = [MusicNotation]()
        self.compMeasures = [Measure]()
        self.curBeat = 0
        self.gNotePlayer = AKSampler()
        self.fNotePlayer = AKSampler()
        self.grandStaffMixerG = AKMixer()
        self.grandStaffMixerF = AKMixer()
        self.setup()
    }
    
    func setup() {
        self.grandStaffMixerG = AKMixer()
        self.grandStaffMixerG.volume = 2.0
        AudioKit.output = self.grandStaffMixerG
    }
    
    func loadSound () {
        do{
            try self.gNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
            try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
        } catch {
            return
        }
    }

    func playNote(note: Note, keySignature: KeySignature){
        print("MIDI Piano Note")

        let FMPiano = AKSampler()
        self.grandStaffMixerG.stop()
        let mixer = AKMixer()
        
        mixer.volume = 2.0
        mixer.connect(input: FMPiano)
        
        FMPiano.volume = 2.0

        do{
            try FMPiano.loadWav("Support Objects/Grand Piano-tailed")
            print("WAV Loaded")
        }catch{
            AKLog("File not found")
            return
        }

        AudioKit.output = mixer
        do{
            try AudioKit.start()
        }catch let error as NSError{
            print(error.debugDescription)
        }
        
        var MIDINum: MIDINoteNumber = 0

        var note = note.duplicate()

        if let ottava = note.ottava {
            if ottava == .eightVa {
                if note.pitch.octave + 1 <= 8 {
                    note.pitch.octave += 1
                } else {
                    note.pitch.octave = 8
                }
            } else if ottava == .eightVb {
                if note.pitch.octave - 1 >= 0 {
                    note.pitch.octave -= 1
                } else {
                    note.pitch.octave = 0
                }
            } else if ottava == .fifteenMa {
                if note.pitch.octave + 2 <= 8 {
                    note.pitch.octave += 2
                } else {
                    note.pitch.octave = 8
                }
            } else if ottava == .fifteenMb {
                if note.pitch.octave - 2 >= 0 {
                    note.pitch.octave -= 2
                } else {
                    note.pitch.octave = 0
                }
            }
        }

        switch note.pitch.step.toString(){
        case "A":
            switch note.pitch.octave{
            case 0: MIDINum = 21
            case 1: MIDINum = 33
            case 2: MIDINum = 45
            case 3: MIDINum = 57
            case 4: MIDINum = 69
            case 5: MIDINum = 81
            case 6: MIDINum = 93
            case 7: MIDINum = 105
            case 8: MIDINum = 117
            default:
                MIDINum = 30
            }
            break
        case "B":
            switch note.pitch.octave{
            case 0: MIDINum = 23
            case 1: MIDINum = 35
            case 2: MIDINum = 47
            case 3: MIDINum = 59
            case 4: MIDINum = 71
            case 5: MIDINum = 83
            case 6: MIDINum = 95
            case 7: MIDINum = 107
            case 8: MIDINum = 119
            default:
                MIDINum = 30
            }
            break
        case "C":
            switch note.pitch.octave{
            case 0: MIDINum = 12
            case 1: MIDINum = 24
            case 2: MIDINum = 36
            case 3: MIDINum = 48
            case 4: MIDINum = 60
            case 5: MIDINum = 72
            case 6: MIDINum = 84
            case 7: MIDINum = 96
            case 8: MIDINum = 108
            default:
                MIDINum = 30
            }
            break
        case "D":
            switch note.pitch.octave{
            case 0: MIDINum = 14
            case 1: MIDINum = 26
            case 2: MIDINum = 38
            case 3: MIDINum = 50
            case 4: MIDINum = 62
            case 5: MIDINum = 74
            case 6: MIDINum = 86
            case 7: MIDINum = 98
            case 8: MIDINum = 110
            default:
                MIDINum = 30
            }
            break
        case "E":
            switch note.pitch.octave{
            case 0: MIDINum = 16
            case 1: MIDINum = 28
            case 2: MIDINum = 40
            case 3: MIDINum = 52
            case 4: MIDINum = 64
            case 5: MIDINum = 76
            case 6: MIDINum = 88
            case 7: MIDINum = 100
            case 8: MIDINum = 112
            default:
                MIDINum = 30
            }
            break
        case "F":
            switch note.pitch.octave{
            case 0: MIDINum = 17
            case 1: MIDINum = 29
            case 2: MIDINum = 41
            case 3: MIDINum = 53
            case 4: MIDINum = 65
            case 5: MIDINum = 77
            case 6: MIDINum = 89
            case 7: MIDINum = 101
            case 8: MIDINum = 113
            default:
                MIDINum = 30
            }
            break
        case "G":
            switch note.pitch.octave{
            case 0: MIDINum = 19
            case 1: MIDINum = 31
            case 2: MIDINum = 43
            case 3: MIDINum = 55
            case 4: MIDINum = 67
            case 5: MIDINum = 79
            case 6: MIDINum = 91
            case 7: MIDINum = 103
            case 8: MIDINum = 115
            default:
                MIDINum = 30
            }
            break

        default:
            break
        }

        switch(keySignature) {
        case .c:
            break
        case .f:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B {
                    MIDINum -= 1
                }
            }
            break
        case .bFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E {
                    MIDINum -= 1
                }
            }
            break
        case .eFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A {
                    MIDINum -= 1
                }
            }
            break
        case .aFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D {
                    MIDINum -= 1
                }
            }
            break
        case .dFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G {
                    MIDINum -= 1
                }
            }
            break
        case .gFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G || notePitch == .C {
                    MIDINum -= 1
                }
            }
            break
        case .cFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G || notePitch == .C || notePitch == .F {
                    MIDINum -= 1
                }
            }
            break
        case .g:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F {
                    MIDINum += 1
                }
            }
            break
        case .d:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C {
                    MIDINum += 1
                }
            }
            break
        case .a:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G {
                    MIDINum += 1
                }
            }
            break
        case .e:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D {
                    MIDINum += 1
                }
            }
            break
        case .b:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A {
                    MIDINum += 1
                }
            }
            break
        case .fSharp:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A || notePitch == .E {
                    MIDINum += 1
                }
            }
            break
        case .cSharp:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A || notePitch == .E || notePitch == .B {
                    MIDINum += 1
                }
            }
            break
        }

        //Sharp handling
        if note.accidental == .sharp {
            MIDINum += 1
        }

        //Flat handling
        if note.accidental == .flat {
            MIDINum -= 1
        }

        if note.accidental == .doubleSharp {
            MIDINum += 2
        }
        
        MIDINum += 3
        FMPiano.play(noteNumber: MIDINum)

    }

    func getNoteMIDINum(note: Note, keySignature: KeySignature) -> Int {

        var MIDINum = 30

        var note = note.duplicate()

        if let ottava = note.ottava {
            if ottava == .eightVa {
                if note.pitch.octave + 1 <= 8 {
                    note.pitch.octave += 1
                } else {
                    note.pitch.octave = 8
                }
            } else if ottava == .eightVb {
                if note.pitch.octave - 1 >= 0 {
                    note.pitch.octave -= 1
                } else {
                    note.pitch.octave = 0
                }
            } else if ottava == .fifteenMa {
                if note.pitch.octave + 2 <= 8 {
                    note.pitch.octave += 2
                } else {
                    note.pitch.octave = 8
                }
            } else if ottava == .fifteenMb {
                if note.pitch.octave - 2 >= 0 {
                    note.pitch.octave -= 2
                } else {
                    note.pitch.octave = 0
                }
            }
        }

        switch note.pitch.step.toString(){
        case "A":
            switch note.pitch.octave{
            case 0: MIDINum = 21
            case 1: MIDINum = 33
            case 2: MIDINum = 45
            case 3: MIDINum = 57
            case 4: MIDINum = 69
            case 5: MIDINum = 81
            case 6: MIDINum = 93
            case 7: MIDINum = 105
            case 8: MIDINum = 117
            default:
                MIDINum = 30
            }
            break
        case "B":
            switch note.pitch.octave{
            case 0: MIDINum = 23
            case 1: MIDINum = 35
            case 2: MIDINum = 47
            case 3: MIDINum = 59
            case 4: MIDINum = 71
            case 5: MIDINum = 83
            case 6: MIDINum = 95
            case 7: MIDINum = 107
            case 8: MIDINum = 119
            default:
                MIDINum = 30
            }
            break
        case "C":
            switch note.pitch.octave{
            case 0: MIDINum = 12
            case 1: MIDINum = 24
            case 2: MIDINum = 36
            case 3: MIDINum = 48
            case 4: MIDINum = 60
            case 5: MIDINum = 72
            case 6: MIDINum = 84
            case 7: MIDINum = 96
            case 8: MIDINum = 108
            default:
                MIDINum = 30
            }
            break
        case "D":
            switch note.pitch.octave{
            case 0: MIDINum = 14
            case 1: MIDINum = 26
            case 2: MIDINum = 38
            case 3: MIDINum = 50
            case 4: MIDINum = 62
            case 5: MIDINum = 74
            case 6: MIDINum = 86
            case 7: MIDINum = 98
            case 8: MIDINum = 110
            default:
                MIDINum = 30
            }
            break
        case "E":
            switch note.pitch.octave{
            case 0: MIDINum = 16
            case 1: MIDINum = 28
            case 2: MIDINum = 40
            case 3: MIDINum = 52
            case 4: MIDINum = 64
            case 5: MIDINum = 76
            case 6: MIDINum = 88
            case 7: MIDINum = 100
            case 8: MIDINum = 112
            default:
                MIDINum = 30
            }
            break
        case "F":
            switch note.pitch.octave{
            case 0: MIDINum = 17
            case 1: MIDINum = 29
            case 2: MIDINum = 41
            case 3: MIDINum = 53
            case 4: MIDINum = 65
            case 5: MIDINum = 77
            case 6: MIDINum = 89
            case 7: MIDINum = 101
            case 8: MIDINum = 113
            default:
                MIDINum = 30
            }
            break
        case "G":
            switch note.pitch.octave{
            case 0: MIDINum = 19
            case 1: MIDINum = 31
            case 2: MIDINum = 43
            case 3: MIDINum = 55
            case 4: MIDINum = 67
            case 5: MIDINum = 79
            case 6: MIDINum = 91
            case 7: MIDINum = 103
            case 8: MIDINum = 115
            default:
                MIDINum = 30
            }
            break

        default:
            break
        }

        switch(keySignature) {
        case .c:
            break
        case .f:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B {
                    MIDINum -= 1
                }
            }
            break
        case .bFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E {
                    MIDINum -= 1
                }
            }
            break
        case .eFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A {
                    MIDINum -= 1
                }
            }
            break
        case .aFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D {
                    MIDINum -= 1
                }
            }
            break
        case .dFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G {
                    MIDINum -= 1
                }
            }
            break
        case .gFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G || notePitch == .C {
                    MIDINum -= 1
                }
            }
            break
        case .cFlat:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .B || notePitch == .E || notePitch == .A || notePitch == .D || notePitch == .G || notePitch == .C || notePitch == .F {
                    MIDINum -= 1
                }
            }
            break
        case .g:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F {
                    MIDINum += 1
                }
            }
            break
        case .d:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C {
                    MIDINum += 1
                }
            }
            break
        case .a:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G {
                    MIDINum += 1
                }
            }
            break
        case .e:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D {
                    MIDINum += 1
                }
            }
            break
        case .b:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A {
                    MIDINum += 1
                }
            }
            break
        case .fSharp:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A || notePitch == .E {
                    MIDINum += 1
                }
            }
            break
        case .cSharp:
            if note.accidental == nil {
                let notePitch = note.pitch.step

                if notePitch == .F || notePitch == .C || notePitch == .G || notePitch == .D || notePitch == .A || notePitch == .E || notePitch == .B {
                    MIDINum += 1
                }
            }
            break
        }

        //Sharp handling
        if note.accidental == .sharp {
            MIDINum += 1
        }

        //Flat handling
        if note.accidental == .flat {
            MIDINum -= 1
        }

        if note.accidental == .doubleSharp {
            MIDINum += 2
        }

        return MIDINum + 3
    }
    
    private func getDurationOfNote (notation: MusicNotation) -> Int {
        var x = 0
        
        switch notation.type {
        case .sixtyFourth:
            x = 8
            if notation.dots == 1 {
                x += 4
            } else if notation.dots == 2 {
                x += 6
            } else if notation.dots == 3 {
                x += 7
            }
        case .thirtySecond:
            x = 16
            if notation.dots == 1 {
                x += 8
            } else if notation.dots == 2 {
                x += 12
            } else if notation.dots == 3 {
                x += 14
            }
        case .sixteenth:
            x = 32
            if notation.dots == 1 {
                x += 16
            } else if notation.dots == 2 {
                x += 24
            } else if notation.dots == 3 {
                x += 28
            }
        case .eighth:
            x = 64
            if notation.dots == 1 {
                x += 32
            } else if notation.dots == 2 {
                x += 48
            } else if notation.dots == 3 {
                x += 56
            }
        case .quarter:
            x = 128
            if notation.dots == 1 {
                x += 64
            } else if notation.dots == 2 {
                x += 96
            } else if notation.dots == 3 {
                x += 112
            }
        case .half:
            x = 256
            if notation.dots == 1 {
                x += 128
            } else if notation.dots == 2 {
                x += 192
            } else if notation.dots == 3 {
                x += 224
            }
        case .whole:
            x = 512
            if notation.dots == 1 {
                x += 32
            } else if notation.dots == 2 {
                x += 48
            } else if notation.dots == 3 {
                x += 56
            }
        default:
            x = 8
        }
        
        return x
    }

    func addNotation(notation: MusicNotation, keySignature: KeySignature) -> [[Int?]] {

        var notePlayer = [[Int?]]()

        var x = self.getDurationOfNote(notation: notation)
        
        if let note = notation as? Note, let conn = note.connection, let connNotes = conn.notes {
            if conn.type == .tie {
                x = 0
                
                for noteConn in connNotes {
                    x += getDurationOfNote(notation: noteConn)
                }
            }
        } else if let chord = notation as? Chord {
            
            var allTies = true
            var nextDuration = 0
            
            for note in chord.notes {
                nextDuration = 0
                if let connection = note.connection {
                    
                    if connection.type == .slur {
                        allTies = false
                    }
                    
                    if let connNotes = connection.notes {
                        for note in connNotes {
                            nextDuration += getDurationOfNote(notation: note)
                        }
                    }
                    
                } else {
                    allTies = false
                }
            }
            
            if allTies {
                x = 0
                x += nextDuration
            }
            
        }

        for beat in 0..<x {
            if let note = notation as? Note {
                if let conn = note.connection, let notes = conn.notes, let first = notes.first {
                    if beat >= 1 {
                        //print("Note Added. Adding the Trailing 0s")
                        notePlayer.append([nil])
                    } else {
                        if note == first && conn.type == .tie {
                            notePlayer.append([getNoteMIDINum(note: note, keySignature: keySignature)])
                        } else if conn.type == .slur {
                            notePlayer.append([getNoteMIDINum(note: note, keySignature: keySignature)])
                        }
                    }
                } else {
                    if beat >= 1 {
                        //print("Note Added. Adding the Trailing 0s")
                        notePlayer.append([nil])
                    } else {
                        notePlayer.append([getNoteMIDINum(note: note, keySignature: keySignature)])
                    }
                }
            } else if let chord = notation as? Chord {
                if beat >= 1 {
                    //print("Note Added. Adding the Trailing 0s")
                    notePlayer.append([nil])
                } else {
                    var n = [Int?]()

                    for note in chord.notes {
                        n.append(getNoteMIDINum(note: note, keySignature: keySignature))
                    }

                    notePlayer.append(n)
                }
            } else {
                notePlayer.append([nil])
            }
        }

        return notePlayer
    }
    
    func addNotationConnType(notation: MusicNotation) -> [[ConnectionType?]] {
        
        var connType = [[ConnectionType?]]()
        
        var x = self.getDurationOfNote(notation: notation)
        
        if let note = notation as? Note, let conn = note.connection, let connNotes = conn.notes {
            if conn.type == .tie {
                x = 0
                
                for noteConn in connNotes {
                    x += getDurationOfNote(notation: noteConn)
                }
            }
        } else if let chord = notation as? Chord {
            
            var allTies = true
            var nextDuration = 0
            
            for note in chord.notes {
                if let connection = note.connection {
                    
                    if connection.type == .slur {
                        allTies = false
                    }
                    
                    if let connNotes = connection.notes {
                        for note in connNotes {
                            nextDuration += getDurationOfNote(notation: note)
                        }
                    }
                    
                } else {
                    allTies = false
                }
            }
            
            if allTies {
                x += nextDuration
            }
            
        }
        
        for beat in 0..<x {
            if let note = notation as? Note {
                if let conn = note.connection, let notes = conn.notes, let first = notes.first {
                    if beat >= 1 {
                        //print("Note Added. Adding the Trailing 0s")
                        connType.append([nil])
                    } else {
                        connType.append([note.connection?.type])
                    }
                } else {
                    if beat >= 1 {
                        //print("Note Added. Adding the Trailing 0s")
                        connType.append([nil])
                    } else {
                        connType.append([note.connection?.type])
                    }
                }
            } else if let chord = notation as? Chord {
                if beat >= 1 {
                    //print("Note Added. Adding the Trailing 0s")
                    connType.append([nil])
                } else {
                    var n = [ConnectionType?]()
                    
                    for note in chord.notes {
                        n.append(note.connection?.type)
                    }
                    
                    connType.append(n)
                }
            } else {
                connType.append([nil])
            }
        }
        
        return connType
    }
    
    func addNotationType(notation: MusicNotation) -> [[RestNoteType?]] {
        
        var noteType = [[RestNoteType?]]()
        
        var x = self.getDurationOfNote(notation: notation)
        
        if let note = notation as? Note, let conn = note.connection, let connNotes = conn.notes {
            if conn.type == .tie {
                x = 0
                
                for noteConn in connNotes {
                    x += getDurationOfNote(notation: noteConn)
                }
            }
        } else if let chord = notation as? Chord {
            
            var allTies = true
            var nextDuration = 0
            
            for note in chord.notes {
                if let connection = note.connection {
                    
                    if connection.type == .slur {
                        allTies = false
                    }
                    
                    if let connNotes = connection.notes {
                        for note in connNotes {
                            nextDuration += getDurationOfNote(notation: note)
                        }
                    }
                    
                } else {
                    allTies = false
                }
            }
            
            if allTies {
                x += nextDuration
            }
            
        }
        
        for beat in 0..<x {
            if let note = notation as? Note {
                if let conn = note.connection, let notes = conn.notes, let first = notes.first {
                    if beat >= 1 {
                        //print("Note Added. Adding the Trailing 0s")
                        noteType.append([nil])
                    } else {
                        noteType.append([note.type])
                    }
                } else {
                    if beat >= 1 {
                        //print("Note Added. Adding the Trailing 0s")
                        noteType.append([nil])
                    } else {
                        noteType.append([note.type])
                    }
                }
            } else if let chord = notation as? Chord {
                if beat >= 1 {
                    //print("Note Added. Adding the Trailing 0s")
                    noteType.append([nil])
                } else {
                    var n = [RestNoteType?]()
                    
                    for note in chord.notes {
                        n.append(note.type)
                    }
                    
                    noteType.append(n)
                }
            } else {
                noteType.append([nil])
            }
        }
        
        return noteType
    }
    
    func playNotations(notations: [MusicNotation], tempo: Double) {
        
        if notations.count > 1 {
            self.timer.invalidate()
            self.grandStaffMixerG.stop()
            self.grandStaffMixerF.stop()
            self.tempo = tempo
            self.loadSound()
            
            self.gNotesMIDI = preProcessNotations(notations: notations)
            //self.fNotesMIDI = preProcessStaff(staff: composition.staffList[1])
            
            do {
                try AudioKit.start()
            } catch let error as NSError{
                print(error.debugDescription)
            }
            
            self.curBeat = 0
            
            if #available(iOS 10.0, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 60 / tempo * 0.0078125, repeats: true) {_ in
                    self.updateTime2()
                }
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 60 / tempo * 0.0078125,
                                                  target: self,
                                                  selector: #selector(self.updateTime2),
                                                  userInfo: nil,
                                                  repeats: true)
            }
            
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        } else {
            if let note = notations[0] as? Note {
                if let keySig = note.measure?.keySignature {
                    self.playNote(note: note, keySignature: keySig)
                }
            } else {
                self.timer.invalidate()
                self.tempo = tempo
                self.loadSound()
                
                self.gNotesMIDI = preProcessNotations(notations: notations)
                //self.fNotesMIDI = preProcessStaff(staff: composition.staffList[1])
                
                do {
                    try AudioKit.start()
                } catch let error as NSError{
                    print(error.debugDescription)
                }
                
                self.curBeat = 0
                
                if #available(iOS 10.0, *) {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 60 / tempo * 0.0078125, repeats: true) {_ in
                        self.updateTime2()
                    }
                } else {
                    self.timer = Timer.scheduledTimer(timeInterval: 60 / tempo * 0.0078125,
                                                      target: self,
                                                      selector: #selector(self.updateTime2),
                                                      userInfo: nil,
                                                      repeats: true)
                }
                
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    @objc
    func updateTime2() {
        if !self.gNotesMIDI.isEmpty && self.curBeat < self.gNotesMIDI.count {
            if self.gNotesMIDI[self.curBeat].count <= 1 {
                if let noteNumber = self.gNotesMIDI[self.curBeat][0] {
                    
                    self.grandStaffMixerG = AKMixer()
                    self.grandStaffMixerG.volume = 2.0
                    AudioKit.output = self.grandStaffMixerG
                    
                    self.gNotePlayer = AKSampler()
                    self.gNotePlayer.volume = 2.0
                    
                    if self.gNotesType[self.curBeat][0] == .whole || self.gNotesType[self.curBeat][0] == .half || self.gNotesConnType[self.curBeat][0] == .slur {
                        do{
                            try self.gNotePlayer.loadWav("Support Objects/Grand Piano-long")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
                        } catch {
                            return
                        }
                    } else {
                        do{
                            try self.gNotePlayer.loadWav("Support Objects/Grand Piano-tailed")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
                        } catch {
                            return
                        }
                    }
                    
                    self.grandStaffMixerG.connect(self.gNotePlayer)
                    
                    self.gNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
                }
            } else {
                self.grandStaffMixerG.stop()
                self.grandStaffMixerG = AKMixer()
                self.grandStaffMixerG.volume = 2.0
                AudioKit.output = self.grandStaffMixerG
                
                for i in gNotesMIDI[self.curBeat] {
                    let player = AKSampler()
                    player.volume = 2.0
                    
                    if self.gNotesType[self.curBeat][0] == .whole || self.gNotesType[self.curBeat][0] == .half || self.gNotesConnType[self.curBeat][0] == .slur {
                        do{
                            try player.loadWav("Support Objects/Grand Piano-long")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
                        } catch {
                            return
                        }
                    } else {
                        do{
                            try player.loadWav("Support Objects/Grand Piano-tailed")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
                        } catch {
                            return
                        }
                    }
                    
                    self.grandStaffMixerG.connect(player)
                    
                    if let n = i {
                        player.play(noteNumber: MIDINoteNumber(n))
                    }
                }
            }
        }
        
        /*if !self.fNotesMIDI.isEmpty && self.curBeat < self.fNotesMIDI.count {
            if self.fNotesMIDI[self.curBeat].count <= 1 {
                if let noteNumber = self.fNotesMIDI[self.curBeat][0] {
                    self.fNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
                }
            } else {
                self.grandStaffMixer = AKMixer()
                self.grandStaffMixer.volume = 2.0
                AudioKit.output = self.grandStaffMixer
                
                for i in fNotesMIDI[self.curBeat] {
                    let player = AKSampler()
                    
                    do{
                        try player.loadWav("Support Objects/Grand Piano")
                    } catch {
                        return
                    }
                    
                    self.grandStaffMixer.connect(player)
                    
                    if let n = i {
                        player.play(noteNumber: MIDINoteNumber(n))
                    }
                }
            }
        }*/
        
        self.curBeat += 1
        
        if self.curBeat > self.gNotesMIDI.count + 5 {
            self.timer.invalidate()
            self.isPlaying = false
        }
        
        /*if Double(curBeat) > self.tempo * co {
         timer.invalidate()
         }*/
    }
    
    func preProcessNotations(notations: [MusicNotation]) -> [[Int?]] {
        
        self.gNotesType.removeAll()
        self.gNotesConnType.removeAll()
        
        var staffPlayer = [[Int?]]()
        var modifiedChord: Chord?
        
        var skipPitches = [Pitch]()
        
        for notation in notations {
            
            if let note = notation as? Note, let conn = note.connection, let notes = conn.notes {
                if let first = notes.first {
                    if note == first {
                        staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: (notation.measure?.keySignature)!))
                        self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                        self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                        
                        if conn.type == .tie {
                            
                            if skipPitches.count > 0 {
                                skipPitches.removeAll()
                            }
                            
                            skipPitches.append(note.pitch)
                        }
                        
                    } else if conn.type == .slur {
                        staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: (notation.measure?.keySignature)!))
                        self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                        self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                    }
                }
            } else if let chord = notation as? Chord {
                
                if skipPitches.count > 0 {
                    let dupliChord = chord.duplicate()
                    
                    for pitch in skipPitches {
                        dupliChord.notes = dupliChord.notes.filter {$0.pitch != pitch}
                    }
                    
                    if dupliChord.notes.count > 0 {
                        staffPlayer.append(contentsOf: addNotation(notation: dupliChord, keySignature: (notation.measure?.keySignature)!))
                        self.gNotesType.append(contentsOf: addNotationType(notation: dupliChord))
                        self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                    }
                    
                    skipPitches.removeAll()
                    
                } else {
                    staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: (notation.measure?.keySignature)!))
                    self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                    self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                }
                
                for note in chord.notes {
                    
                    if let connection = note.connection, let notes = connection.notes {
                        if let first = notes.first {
                            if note == first {
                                if notes.count > 1 {
                                    if connection.type != .slur { // slur check
                                        skipPitches.append(note.pitch)
                                    }
                                }
                            } else {
                                modifiedChord = chord.duplicate()
                                
                                if connection.type != .slur {
                                    modifiedChord?.removeNote(note: note)
                                }
                            }
                        }
                    }
                    
                }
                
                
                
            } else {
                staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: (notation.measure?.keySignature)!))
                self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                
                if skipPitches.count > 0 {
                    skipPitches.removeAll()
                }
            }
        }
        
        return staffPlayer
    }
    
    func preProcessStaffFrom(startingMeasureIndex: Int, startingNoteIndex: Int, staff: Staff, clef: Clef, skipAmount: Float = 0) -> [[Int?]] {
        var staffPlayer = [[Int?]]()
        var modifiedChord: Chord?
        
        if clef == .G {
            self.gNotesType.removeAll()
            self.gNotesConnType.removeAll()
        } else if clef == .F {
            self.fNotesType.removeAll()
            self.fNotesConnType.removeAll()
        }
        
        var skipPitches = [Pitch]()
        var alreadySkippedAmt = false
        
        for (index, measure) in staff.measures.enumerated() {
            
            if index < startingMeasureIndex {
                continue
            }
            
            for (notationIndex, notation) in measure.notationObjects.enumerated() {
                
                if index == startingMeasureIndex {
                    if notationIndex < startingNoteIndex {
                        continue
                    } else if skipAmount > 0 && !alreadySkippedAmt { // if current note doesnt have a parallel note, create imaginary rest
                        
                        var trailingRest: Rest?
                        
                        for type in RestNoteType.types {
                            for dots in 0...3 {
                                if type.getBeatValue(dots: dots) == skipAmount {
                                    trailingRest = Rest(type: type, dots: dots)
                                }
                            }
                        }
                        
                        if let trailingRest = trailingRest {
                            let addNotation = self.addNotation(notation: trailingRest, keySignature: measure.keySignature)
                            staffPlayer.append(contentsOf: addNotation)
                            
                            if clef == .G {
                                for _ in 0..<addNotation.count {
                                    gNotes.append(trailingRest)
                                }
                            } else if clef == .F {
                                for _ in 0..<addNotation.count {
                                    fNotes.append(trailingRest)
                                }
                            }
                            
                            alreadySkippedAmt = true
                            continue
                        }
                    }
                }
                
                if let note = notation as? Note, let conn = note.connection, let notes = conn.notes {
                    if let first = notes.first {
                        if note == first {
                            let addNotation = self.addNotation(notation: notation, keySignature: measure.keySignature)
                            staffPlayer.append(contentsOf: addNotation)
                            
                            if clef == .G {
                                self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            } else if clef == .F {
                                self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            }
                            
                            if clef == .G {
                                for _ in 0..<addNotation.count {
                                    gNotes.append(notation)
                                }
                            } else if clef == .F {
                                for _ in 0..<addNotation.count {
                                    fNotes.append(notation)
                                }
                            }
                            
                            if conn.type == .tie {
                                
                                if skipPitches.count > 0 {
                                    skipPitches.removeAll()
                                }
                                
                                skipPitches.append(note.pitch)
                            }
                            
                        } else if conn.type == .slur {
                            let addNotation = self.addNotation(notation: notation, keySignature: measure.keySignature)
                            staffPlayer.append(contentsOf: addNotation)
                            
                            if clef == .G {
                                self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            } else if clef == .F {
                                self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            }
                            
                            if clef == .G {
                                for _ in 0..<addNotation.count {
                                    gNotes.append(notation)
                                }
                            } else if clef == .F {
                                for _ in 0..<addNotation.count {
                                    fNotes.append(notation)
                                }
                            }
                        }
                    }
                } else if let chord = notation as? Chord {
                    
                    if skipPitches.count > 0 {
                        let dupliChord = chord.duplicate()
                        
                        for pitch in skipPitches {
                            dupliChord.notes = dupliChord.notes.filter {$0.pitch != pitch}
                        }
                        
                        if dupliChord.notes.count > 0 {
                            let addNotation = self.addNotation(notation: dupliChord, keySignature: measure.keySignature)
                            staffPlayer.append(contentsOf: addNotation)
                            
                            if clef == .G {
                                self.gNotesType.append(contentsOf: addNotationType(notation: dupliChord))
                                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: dupliChord))
                            } else if clef == .F {
                                self.fNotesType.append(contentsOf: addNotationType(notation: dupliChord))
                                self.fNotesConnType.append(contentsOf: addNotationConnType(notation: dupliChord))
                            }
                            
                            if clef == .G {
                                for _ in 0..<addNotation.count {
                                    gNotes.append(notation)
                                }
                            } else if clef == .F {
                                for _ in 0..<addNotation.count {
                                    fNotes.append(notation)
                                }
                            }
                        }
                        
                        skipPitches.removeAll()
                        
                    } else {
                        let addNotation = self.addNotation(notation: notation, keySignature: measure.keySignature)
                        staffPlayer.append(contentsOf: addNotation)
                        
                        if clef == .G {
                            self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                            self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                        } else if clef == .F {
                            self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                            self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                        }
                        
                        if clef == .G {
                            for _ in 0..<addNotation.count {
                                gNotes.append(notation)
                            }
                        } else if clef == .F {
                            for _ in 0..<addNotation.count {
                                fNotes.append(notation)
                            }
                        }
                    }
                    
                    for note in chord.notes {
                        
                        if let connection = note.connection, let notes = connection.notes {
                            if let first = notes.first {
                                if note == first {
                                    if notes.count > 1 {
                                        if connection.type != .slur { // slur check
                                            skipPitches.append(note.pitch)
                                        }
                                    }
                                } else {
                                    modifiedChord = chord.duplicate()
                                    
                                    if connection.type != .slur {
                                        modifiedChord?.removeNote(note: note)
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    
                    
                } else {
                    let addNotation = self.addNotation(notation: notation, keySignature: measure.keySignature)
                    staffPlayer.append(contentsOf: addNotation)
                    
                    if clef == .G {
                        self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                        self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                    } else if clef == .F {
                        self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                        self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                    }
                    
                    if clef == .G {
                        for _ in 0..<addNotation.count {
                            gNotes.append(notation)
                        }
                    } else if clef == .F {
                        for _ in 0..<addNotation.count {
                            fNotes.append(notation)
                        }
                    }
                    
                    if skipPitches.count > 0 {
                        skipPitches.removeAll()
                    }
                }
                
            }
        }
        
        return staffPlayer
    }

    func preProcessStaff(staff: Staff) -> [[Int?]] {
        var staffPlayer = [[Int?]]()
        var modifiedChord: Chord?
        
        if staff.measures[0].clef == .G {
            self.gNotesType.removeAll()
            self.gNotesConnType.removeAll()
        } else if staff.measures[0].clef == .F {
            self.fNotesType.removeAll()
            self.fNotesConnType.removeAll()
        }
        
        var skipPitches = [Pitch]()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                
                if let note = notation as? Note, let conn = note.connection, let notes = conn.notes {
                    if let first = notes.first {
                        if note == first {
                            staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: measure.keySignature))
                            
                            if measure.clef == .G {
                                self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            } else if measure.clef == .F {
                                self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            }
                            
                            if conn.type == .tie {
                                
                                if skipPitches.count > 0 {
                                    skipPitches.removeAll()
                                }
                                
                                skipPitches.append(note.pitch)
                            }
                            
                        } else if conn.type == .slur {
                            staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: measure.keySignature))
                            
                            if measure.clef == .G {
                                self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            } else if measure.clef == .F {
                                self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                                self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                            }
                        }
                    }
                } else if let chord = notation as? Chord {
                    
                    if skipPitches.count > 0 {
                        let dupliChord = chord.duplicate()
                        
                        for pitch in skipPitches {
                            dupliChord.notes = dupliChord.notes.filter {$0.pitch != pitch}
                        }
                        
                        if dupliChord.notes.count > 0 {
                            staffPlayer.append(contentsOf: addNotation(notation: dupliChord, keySignature: measure.keySignature))
                            
                            if measure.clef == .G {
                                self.gNotesType.append(contentsOf: addNotationType(notation: dupliChord))
                                self.gNotesConnType.append(contentsOf: addNotationConnType(notation: dupliChord))
                            } else if measure.clef == .F {
                                self.fNotesType.append(contentsOf: addNotationType(notation: dupliChord))
                                self.fNotesConnType.append(contentsOf: addNotationConnType(notation: dupliChord))
                            }
                        }
                        
                        skipPitches.removeAll()
                       
                    } else {
                        staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: measure.keySignature))
                        
                        if measure.clef == .G {
                            self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                            self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                        } else if measure.clef == .F {
                            self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                            self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                        }
                    }
                    
                    for note in chord.notes {
                        
                        if let connection = note.connection, let notes = connection.notes {
                            if let first = notes.first {
                                if note == first {
                                    if notes.count > 1 {
                                        if connection.type != .slur { // slur check
                                            skipPitches.append(note.pitch)
                                        }
                                    }
                                } else {
                                    modifiedChord = chord.duplicate()
                                    
                                    if connection.type != .slur {
                                        modifiedChord?.removeNote(note: note)
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    
                    
                } else {
                    staffPlayer.append(contentsOf: addNotation(notation: notation, keySignature: measure.keySignature))
                    
                    if measure.clef == .G {
                        self.gNotesType.append(contentsOf: addNotationType(notation: notation))
                        self.gNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                    } else if measure.clef == .F {
                        self.fNotesType.append(contentsOf: addNotationType(notation: notation))
                        self.fNotesConnType.append(contentsOf: addNotationConnType(notation: notation))
                    }
                    
                    if skipPitches.count > 0 {
                        skipPitches.removeAll()
                    }
                }

            }
        }

        return staffPlayer
    }

    func getCompMeasures (comp: Composition) -> [Measure] {
        var measures = [Measure]()

        if let firstStaff = comp.staffList.first {
            for measure in firstStaff.measures {
                for notation in measure.notationObjects {
                    let x = self.getDurationOfNote(notation: notation)

                    for _ in 0..<x {
                        measures.append(measure)
                    }
                }
            }
        }

        return measures
    }
    
    func getCompMeasureStarting (from: Measure, comp: Composition) -> [Measure] {
        var measures = [Measure]()
        
        if let firstStaff = comp.staffList.first {
            
            if let startingIndex = firstStaff.measures.index(of: from) {
            
                for (index, measure) in firstStaff.measures.enumerated() {
                    
                    if index < startingIndex {
                        continue
                    }
                    
                    for notation in measure.notationObjects {
                        let x = self.getDurationOfNote(notation: notation)
                        
                        for _ in 0..<x {
                            measures.append(measure)
                        }
                    }
                    
                }
            }
        }
        
        return measures
    }
    
    func getCompMeasureStarting (from: MusicNotation, comp: Composition) -> [Measure] {
        var measures = [Measure]()
        
        if let firstStaff = comp.staffList.first {
            
            var notationToBeChecked = from
            
            if let note = from as? Note, let chord = note.chord {
                notationToBeChecked = chord
            }
            
            if let notationMeasure = notationToBeChecked.measure, let notationIndex = notationMeasure.notationObjects.index(of: notationToBeChecked) {
            
                if let startingIndex = firstStaff.measures.index(of: notationMeasure) {
                    
                    for (index, measure) in firstStaff.measures.enumerated() {
                        
                        if index < startingIndex {
                            continue
                        }
                        
                        if measure == notationMeasure {
                            
                            for (currNotationIndex, notation) in measure.notationObjects.enumerated() {
                                
                                if currNotationIndex < notationIndex {
                                    continue
                                }
                                
                                let x = self.getDurationOfNote(notation: notation)
                                
                                for _ in 0..<x {
                                    measures.append(measure)
                                }
                            }
                            
                        } else {
                        
                            for notation in measure.notationObjects {
                                let x = self.getDurationOfNote(notation: notation)
                                
                                for _ in 0..<x {
                                    measures.append(measure)
                                }
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
        
        return measures
    }

    func stopPlaying() {
        self.timer.invalidate()
        self.grandStaffMixerG.stop()
        self.grandStaffMixerF.stop()
        do {
            /*try AudioKit.stop()
            gNotePlayer.stop()
            fNotePlayer.stop()*/
        } catch let error as NSError{
            print(error.debugDescription)
        }
        currentMeasurePlaying = nil
        EventBroadcaster.instance.postEvent(event: EventNames.STOP_PLAYBACK)
        
        let params = Parameters()
        params.put(key: KeyNames.TRANSFORM_VIEW_TOGGLE, value: false)
        
        EventBroadcaster.instance.postEvent(event: EventNames.TOGGLE_TRANSFORM_VIEWS, params: params)
    }
    
    func musicPlayback(_ composition: Composition){
        self.stopPlaying()
        
        let params = Parameters()
        params.put(key: KeyNames.TRANSFORM_VIEW_TOGGLE, value: true)
        
        EventBroadcaster.instance.postEvent(event: EventNames.TOGGLE_TRANSFORM_VIEWS, params: params)
        //self.timer.invalidate()
        self.tempo = composition.tempo
        
        self.loadSound()
        
        var currentMeasureIndex = 0
        
        if let currentMeasure = GridSystem.instance.getCurrentMeasure() {
            for staff in composition.staffList {
                if staff.measures.contains(currentMeasure) {
                    if let index = staff.measures.index(of: currentMeasure) {
                        currentMeasureIndex = index
                    }
                }
            }
        }
        
        gNotes.removeAll()
        fNotes.removeAll()
        
        if let selectedCoord = GridSystem.instance.selectedCoord, let noteFromX = GridSystem.instance.getNoteFromX(x: selectedCoord.x), let currentMeasure = GridSystem.instance.getCurrentMeasure() {
            
            var noteToBeChecked = noteFromX
            
            if let note = noteFromX as? Note, let chord = note.chord {
                noteToBeChecked = chord
            }
            
            if let currentNoteIndex = currentMeasure.notationObjects.index(of: noteToBeChecked) {
            
                var gStartIndex = 0
                var fStartIndex = 0
                
                var gSkipAmount: Float = 0
                var fSkipAmount: Float = 0
                
                if currentMeasure.clef == .G {
                    gStartIndex = currentNoteIndex
                } else if currentMeasure.clef == .F {
                    fStartIndex = currentNoteIndex
                }
                
                if currentNoteIndex != 0 {
                    var amountBeforeIndex: Float = 0
                
                    for staff in composition.staffList {
                        
                        if staff.measures[0].clef == currentMeasure.clef {
                            var cntDownIndex = currentNoteIndex - 1
                            
                            while cntDownIndex >= 0 {
                                amountBeforeIndex += currentMeasure.notationObjects[cntDownIndex].getBeatValue()
                                
                                cntDownIndex -= 1
                            }
                        }
                        
                    }
                    
                    for staff in composition.staffList {
                        
                        if staff.measures[0].clef != currentMeasure.clef {
                            let parallelMeasure = staff.measures[currentMeasureIndex]
                            
                            if !parallelMeasure.notationObjects.isEmpty {
                            
                                var startIndex = 0
                                var currentAmount: Float = 0
                                
                                while currentAmount <= amountBeforeIndex {
                                    currentAmount += parallelMeasure.notationObjects[startIndex].getBeatValue()
                                    startIndex += 1
                                }
                                //currentAmount -= parallelMeasure.notationObjects[startIndex].getBeatValue()
                                
                                if currentAmount >= amountBeforeIndex {
                                    if parallelMeasure.clef == .G {
                                        gSkipAmount = currentAmount - amountBeforeIndex
                                    } else if parallelMeasure.clef == .F {
                                        fSkipAmount = currentAmount - amountBeforeIndex
                                    }
                                }
                                
                                startIndex -= 1
                                
                                if parallelMeasure.clef == .G {
                                    gStartIndex = startIndex
                                } else if parallelMeasure.clef == .F {
                                    fStartIndex = startIndex
                                }
                                
                            }
                        }
                        
                    }
                }
            
                self.gNotesMIDI = preProcessStaffFrom(startingMeasureIndex: currentMeasureIndex, startingNoteIndex: gStartIndex, staff: composition.staffList[0], clef: Clef.G, skipAmount: gSkipAmount)
                self.fNotesMIDI = preProcessStaffFrom(startingMeasureIndex: currentMeasureIndex, startingNoteIndex: fStartIndex, staff: composition.staffList[1], clef: Clef.F, skipAmount: fSkipAmount)
                
                print("NOTES TYPE COUNT: \(self.gNotesType.count)")
            
            }
            
        } else {
            self.gNotesMIDI = preProcessStaff(staff: composition.staffList[0])
            self.fNotesMIDI = preProcessStaff(staff: composition.staffList[1])
        }
        
        if let selectedCoord = GridSystem.instance.selectedCoord, let noteFromX = GridSystem.instance.getNoteFromX(x: selectedCoord.x) {

            self.compMeasures = getCompMeasureStarting(from: noteFromX, comp: composition)
            
        } else {
            
            self.compMeasures = getCompMeasures(comp: composition)
            
        }
        
        do {
            try AudioKit.start()
        } catch let error as NSError{
            print(error.debugDescription)
        }

        self.curBeat = 0

        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 60 / tempo * 0.0078125, repeats: true) {_ in
                self.updateTime()
            }
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: 60 / tempo * 0.0078125,
                                 target: self,
                                 selector: #selector(self.updateTime),
                                 userInfo: nil,
                                 repeats: true)
        }

        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    public var currentGNotePlaying: MusicNotation?
    public var currentFNotePlaying: MusicNotation?
    
    private var currentMeasurePlaying: Measure? {
        didSet {
            if currentMeasurePlaying != oldValue {
                let params = Parameters()
                params.put(key: KeyNames.HIGHLIGHT_MEASURE, value: currentMeasurePlaying)
                
                EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_MEASURE, params: params)
            }
        }
    }
    
    @objc
    func updateTime() {
        
        if self.curBeat < self.gNotes.count && self.curBeat < self.fNotes.count && isPlaying {
            
            currentGNotePlaying = gNotes[self.curBeat]
            currentFNotePlaying = fNotes[self.curBeat]
            
            /*if gNotes[self.curBeat].type.getBeatValue() <= fNotes[self.curBeat].type.getBeatValue() {
                self.currentNotePlaying = gNotes[self.curBeat]
            } else if fNotes[self.curBeat].type.getBeatValue() <= gNotes[self.curBeat].type.getBeatValue() {
                self.currentNotePlaying = fNotes[self.curBeat]
            }*/
        }
        
        if !self.gNotesMIDI.isEmpty && self.curBeat < self.gNotesMIDI.count {
            //print("NOTES TYPE COUNT: \(self.gNotesType.count)")
            if self.gNotesMIDI[self.curBeat].count <= 1 {
                if let noteNumber = self.gNotesMIDI[self.curBeat][0] {
                    
                    
                    self.grandStaffMixerG = AKMixer()
                    self.grandStaffMixerG.volume = 2.0
                    AudioKit.output = self.grandStaffMixerG
                    
                    self.gNotePlayer = AKSampler()
                    self.gNotePlayer.volume = 2.0
                    
                    if self.gNotesType[self.curBeat][0] == .whole || self.gNotesType[self.curBeat][0] == .half || self.gNotesConnType[self.curBeat][0] == .slur {
                        do{
                            
                            try self.gNotePlayer.loadWav("Support Objects/Grand Piano-long")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
                        } catch {
                            return
                        }
                    } else {
                        do{
                            try self.gNotePlayer.loadWav("Support Objects/Grand Piano-tailed")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
                        } catch {
                            return
                        }
                    }

                    self.grandStaffMixerG.connect(self.gNotePlayer)
                    
                    self.gNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
                }
            } else {
                //self.grandStaffMixerG.stop()
                self.grandStaffMixerG = AKMixer()
                self.grandStaffMixerG.volume = 2.0
                AudioKit.output = self.grandStaffMixerG

                for i in gNotesMIDI[self.curBeat] {
                    var player = AKSampler()
                    player.volume = 2.0
                    
                    if self.gNotesType[self.curBeat][0] == .whole || self.gNotesType[self.curBeat][0] == .half || self.gNotesConnType[self.curBeat][0] == .slur {
                        do{
                            try player.loadWav("Support Objects/Grand Piano-long")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
                        } catch {
                            return
                        }
                    } else {
                        do{
                            try player.loadWav("Support Objects/Grand Piano-tailed")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
                        } catch {
                            return
                        }
                    }

                    self.grandStaffMixerG.connect(player)

                    if let n = i {
                        player.play(noteNumber: MIDINoteNumber(n))
                    }
                }
            }
        }
        
        if !self.fNotesMIDI.isEmpty && self.curBeat < self.fNotesMIDI.count {
            
            if self.fNotesMIDI[self.curBeat].count <= 1 {
                if let noteNumber = self.fNotesMIDI[self.curBeat][0] {
                    
                    
                    self.grandStaffMixerF = AKMixer()
                    self.grandStaffMixerF.volume = 2.0
                    AudioKit.output = self.grandStaffMixerF
                    
                    self.fNotePlayer = AKSampler()
                    self.fNotePlayer.volume = 2.0
                    
                    if self.fNotesType[self.curBeat][0] == .whole || self.fNotesType[self.curBeat][0] == .half || self.fNotesConnType[self.curBeat][0] == .slur {
                        do{
                            try self.fNotePlayer.loadWav("Support Objects/Grand Piano-long")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
                        } catch {
                            return
                        }
                    } else {
                        do{
                            try self.fNotePlayer.loadWav("Support Objects/Grand Piano-tailed")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
                        } catch {
                            return
                        }
                    }
                    
                    self.grandStaffMixerF.connect(self.fNotePlayer)
                    
                    self.fNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
                }
            } else {
                //self.grandStaffMixerF.stop()
                self.grandStaffMixerF = AKMixer()
                self.grandStaffMixerF.volume = 2.0
                AudioKit.output = self.grandStaffMixerF

                for i in fNotesMIDI[self.curBeat] {
                    var player = AKSampler()
                    player.volume = 2.0
                    
                    if self.fNotesType[self.curBeat][0] == .whole || self.fNotesType[self.curBeat][0] == .half || self.fNotesConnType[self.curBeat][0] == .slur {
                        do{
                            try player.loadWav("Support Objects/Grand Piano-long")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
                        } catch {
                            return
                        }
                    } else {
                        do{
                            try player.loadWav("Support Objects/Grand Piano-tailed")
                            //try self.fNotePlayer.loadWav("Support Objects/Grand Piano-trimmed")
                        } catch {
                            return
                        }
                    }

                    self.grandStaffMixerF.connect(player)

                    if let n = i {
                        player.play(noteNumber: MIDINoteNumber(n))
                    }
                }
            }
        }
        
        if self.curBeat < self.compMeasures.count {
            if !self.compMeasures.isEmpty {
                currentMeasurePlaying = self.compMeasures[self.curBeat]
            }
        }
        
        self.curBeat += 1
        
        if self.curBeat > self.gNotesMIDI.count + 5 && self.curBeat > self.fNotesMIDI.count + 5 {
            self.stopPlaying()
            self.isPlaying = false
            
            self.currentGNotePlaying = nil
            self.currentFNotePlaying = nil
        }
        
        /*if Double(curBeat) > self.tempo * co {
         timer.invalidate()
         }*/
    }
}







