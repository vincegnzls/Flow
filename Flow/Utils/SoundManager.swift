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
    
    init() {
        self.tempo = 120
        self.isPlaying = false
    }

    func playNote(note: Note){
        print("MIDI Piano Note")

        let FMPiano = AKSampler()

        do{
            try FMPiano.loadWav("Support Objects/Grand Piano")
            print("WAV Loaded")
        }catch{
            AKLog("File not found")
            return
        }

        AudioKit.output = FMPiano
        do{
            try AudioKit.start()
        }catch let error as NSError{
            print(error.debugDescription)
        }

        switch note.pitch.step.toString(){
        case "A":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 21)
            case 1: FMPiano.play(noteNumber: 33)
            case 2: FMPiano.play(noteNumber: 45)
            case 3: FMPiano.play(noteNumber: 57)
            case 4: FMPiano.play(noteNumber: 69)
            case 5: FMPiano.play(noteNumber: 81)
            case 6: FMPiano.play(noteNumber: 93)
            case 7: FMPiano.play(noteNumber: 105)
            case 8: FMPiano.play(noteNumber: 117)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break
        case "B":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 23)
            case 1: FMPiano.play(noteNumber: 35)
            case 2: FMPiano.play(noteNumber: 47)
            case 3: FMPiano.play(noteNumber: 59)
            case 4: FMPiano.play(noteNumber: 71)
            case 5: FMPiano.play(noteNumber: 83)
            case 6: FMPiano.play(noteNumber: 95)
            case 7: FMPiano.play(noteNumber: 107)
            case 8: FMPiano.play(noteNumber: 119)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break
        case "C":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 12)
            case 1: FMPiano.play(noteNumber: 24)
            case 2: FMPiano.play(noteNumber: 36)
            case 3: FMPiano.play(noteNumber: 48)
            case 4: FMPiano.play(noteNumber: 60)
            case 5: FMPiano.play(noteNumber: 72)
            case 6: FMPiano.play(noteNumber: 84)
            case 7: FMPiano.play(noteNumber: 96)
            case 8: FMPiano.play(noteNumber: 108)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break
        case "D":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 14)
            case 1: FMPiano.play(noteNumber: 26)
            case 2: FMPiano.play(noteNumber: 38)
            case 3: FMPiano.play(noteNumber: 50)
            case 4: FMPiano.play(noteNumber: 62)
            case 5: FMPiano.play(noteNumber: 74)
            case 6: FMPiano.play(noteNumber: 86)
            case 7: FMPiano.play(noteNumber: 98)
            case 8: FMPiano.play(noteNumber: 110)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break
        case "E":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 16)
            case 1: FMPiano.play(noteNumber: 28)
            case 2: FMPiano.play(noteNumber: 40)
            case 3: FMPiano.play(noteNumber: 52)
            case 4: FMPiano.play(noteNumber: 64)
            case 5: FMPiano.play(noteNumber: 76)
            case 6: FMPiano.play(noteNumber: 88)
            case 7: FMPiano.play(noteNumber: 100)
            case 8: FMPiano.play(noteNumber: 112)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break
        case "F":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 17)
            case 1: FMPiano.play(noteNumber: 29)
            case 2: FMPiano.play(noteNumber: 41)
            case 3: FMPiano.play(noteNumber: 53)
            case 4: FMPiano.play(noteNumber: 65)
            case 5: FMPiano.play(noteNumber: 77)
            case 6: FMPiano.play(noteNumber: 89)
            case 7: FMPiano.play(noteNumber: 101)
            case 8: FMPiano.play(noteNumber: 113)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break
        case "G":
            switch note.pitch.octave{
            case 0: FMPiano.play(noteNumber: 19)
            case 1: FMPiano.play(noteNumber: 31)
            case 2: FMPiano.play(noteNumber: 43)
            case 3: FMPiano.play(noteNumber: 55)
            case 4: FMPiano.play(noteNumber: 67)
            case 5: FMPiano.play(noteNumber: 79)
            case 6: FMPiano.play(noteNumber: 91)
            case 7: FMPiano.play(noteNumber: 103)
            case 8: FMPiano.play(noteNumber: 115)
            default:
                FMPiano.play(noteNumber: 30)
            }
            break

        default:
            break
        }

    }

    func getNoteMIDINum(note: Note) -> Int {

        var MIDINum = 30

        if note.accidental == .sharp || note.accidental == .doubleSharp {
            note.transposeUp()
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

        //Sharp handling
        if note.accidental == .sharp && (note.pitch.step.toString() == "C" || note.pitch.step.toString() == "D" || note.pitch.step.toString() == "F" || note.pitch.step.toString() == "G" || note.pitch.step.toString() == "A"){
            MIDINum += 1
        }

        //Flat handling
        if note.accidental == .flat && (note.pitch.step.toString() == "B" || note.pitch.step.toString() == "E" || note.pitch.step.toString() == "A" || note.pitch.step.toString() == "D" || note.pitch.step.toString() == "G" || note.pitch.step.toString() == "C" || note.pitch.step.toString() == "F"){
            MIDINum -= 1
        }

        return MIDINum
    }

    func addNotation(notation: MusicNotation) -> [Int?] {

        var notePlayer = [Int?]()

        var x = 0

        switch notation.type.toString() {
            case "64th":
                x = 1
            case "32nd":
                x = 2
            case "16th":
                x = 4
            case "eigth":
                x = 8
            case "quarter":
                x = 16
            case "half":
                x = 32
            case "whole":
                x = 64
            default:
                x = 8
        }

        for beat in 0..<x {
            if let note = notation as? Note {
                if beat >= 1 {
                    print("Note Added. Adding the Trailing 0s")
                    notePlayer.append(nil)
                } else {
                    notePlayer.append(getNoteMIDINum(note: note))
                }
            } else {
                notePlayer.append(nil)
            }
        }

        return notePlayer
    }

    func preProcessStaff(staff: Staff) -> [Int?] {
        var staffPlayer = [Int?]()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                staffPlayer.append(contentsOf: addNotation(notation: notation))
            }
        }

        return staffPlayer
    }

    func stopPlaying() {
        self.timer.invalidate()
        EventBroadcaster.instance.postEvent(event: EventNames.STOP_PLAYBACK)
    }
    
    func musicPlayback(_ composition: Composition){
        self.timer.invalidate()

        var gNotesMIDI = preProcessStaff(staff: composition.staffList[0])
        var fNotesMIDI = preProcessStaff(staff: composition.staffList[1])

        print(gNotesMIDI)
        print(fNotesMIDI)

        //Set the players
        let gNotePlayer = AKSampler()

        do{
            try gNotePlayer.loadWav("Support Objects/Grand Piano")
            print("G Player Ready")
        } catch{
            AKLog("File not found")
            return
        }

        let fNotePlayer = AKSampler()

        do{
            try fNotePlayer.loadWav("Support Objects/Grand Piano")
            print("F Player Ready")
        } catch{
            AKLog("File not found")
            return
        }

        let grandStaffMix = AKMixer(fNotePlayer, gNotePlayer)

        AudioKit.output = grandStaffMix
        do{
            try AudioKit.start()
        }catch let error as NSError{
            print(error.debugDescription)
        }

        var curBeat = 0

        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 60 / tempo * 0.0625, repeats: true) {_ in

                if !gNotesMIDI.isEmpty && curBeat < gNotesMIDI.count {
                    if let noteNumber = gNotesMIDI[curBeat] {
                        gNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
                    }
                }

                if !fNotesMIDI.isEmpty && curBeat < fNotesMIDI.count {
                    if let noteNumber = fNotesMIDI[curBeat] {
                        fNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
                    }
                }

                curBeat += 1

                if curBeat > gNotesMIDI.count + 5 && curBeat > fNotesMIDI.count + 5 {
                    self.stopPlaying()
                    self.isPlaying = false
                }

                /*if Double(curBeat) > self.tempo * co {
                    timer.invalidate()
                }*/
            }
        }

    }
}







