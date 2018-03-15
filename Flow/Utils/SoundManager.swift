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
    
    var gNotesMIDI: [Int?]
    var fNotesMIDI: [Int?]
    
    let gNotePlayer: AKSampler
    let fNotePlayer: AKSampler
    
    var grandStaffMixer: AKMixer
    
    var curBeat: Int
    
    init() {
        self.tempo = 120
        self.isPlaying = false
        self.gNotesMIDI = [Int?]()
        self.fNotesMIDI = [Int?]()
        self.curBeat = 0
        self.gNotePlayer = AKSampler()
        self.fNotePlayer = AKSampler()
        self.grandStaffMixer = AKMixer()
        self.setup()
    }
    
    func setup() {
        self.grandStaffMixer = AKMixer(self.fNotePlayer, self.gNotePlayer)
        self.grandStaffMixer.volume = 5.0
        AudioKit.output = self.grandStaffMixer
    }
    
    func loadSound () {
        do{
            try self.gNotePlayer.loadWav("Support Objects/Grand Piano")
            try self.fNotePlayer.loadWav("Support Objects/Grand Piano")
        } catch {
            return
        }
    }

    func playNote(note: Note){
        print("MIDI Piano Note")

        let FMPiano = AKSampler()
        
        FMPiano.volume = 5.0

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
        
        var noteNumber: MIDINoteNumber = 0

        switch note.pitch.step.toString(){
        case "A":
            switch note.pitch.octave{
            case 0: noteNumber = 21
            case 1: noteNumber = 33
            case 2: noteNumber = 45
            case 3: noteNumber = 57
            case 4: noteNumber = 69
            case 5: noteNumber = 81
            case 6: noteNumber = 93
            case 7: noteNumber = 105
            case 8: noteNumber = 117
            default:
                noteNumber = 30
            }
            break
        case "B":
            switch note.pitch.octave{
            case 0: noteNumber = 23
            case 1: noteNumber = 35
            case 2: noteNumber = 47
            case 3: noteNumber = 59
            case 4: noteNumber = 71
            case 5: noteNumber = 83
            case 6: noteNumber = 95
            case 7: noteNumber = 107
            case 8: noteNumber = 119
            default:
                noteNumber = 30
            }
            break
        case "C":
            switch note.pitch.octave{
            case 0: noteNumber = 12
            case 1: noteNumber = 24
            case 2: noteNumber = 36
            case 3: noteNumber = 48
            case 4: noteNumber = 60
            case 5: noteNumber = 72
            case 6: noteNumber = 84
            case 7: noteNumber = 96
            case 8: noteNumber = 108
            default:
                noteNumber = 30
            }
            break
        case "D":
            switch note.pitch.octave{
            case 0: noteNumber = 14
            case 1: noteNumber = 26
            case 2: noteNumber = 38
            case 3: noteNumber = 50
            case 4: noteNumber = 62
            case 5: noteNumber = 74
            case 6: noteNumber = 86
            case 7: noteNumber = 98
            case 8: noteNumber = 110
            default:
                noteNumber = 30
            }
            break
        case "E":
            switch note.pitch.octave{
            case 0: noteNumber = 16
            case 1: noteNumber = 28
            case 2: noteNumber = 40
            case 3: noteNumber = 52
            case 4: noteNumber = 64
            case 5: noteNumber = 76
            case 6: noteNumber = 88
            case 7: noteNumber = 100
            case 8: noteNumber = 112
            default:
                noteNumber = 30
            }
            break
        case "F":
            switch note.pitch.octave{
            case 0: noteNumber = 17
            case 1: noteNumber = 29
            case 2: noteNumber = 41
            case 3: noteNumber = 53
            case 4: noteNumber = 65
            case 5: noteNumber = 77
            case 6: noteNumber = 89
            case 7: noteNumber = 101
            case 8: noteNumber = 113
            default:
                noteNumber = 30
            }
            break
        case "G":
            switch note.pitch.octave{
            case 0: noteNumber = 19
            case 1: noteNumber = 31
            case 2: noteNumber = 43
            case 3: noteNumber = 55
            case 4: noteNumber = 67
            case 5: noteNumber = 79
            case 6: noteNumber = 91
            case 7: noteNumber = 103
            case 8: noteNumber = 115
            default:
                noteNumber = 30
            }
            break

        default:
            break
        }
        
        noteNumber += 3
        FMPiano.play(noteNumber: noteNumber)

    }

    func getNoteMIDINum(note: Note) -> Int {

        var MIDINum = 30

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
        if note.accidental == .sharp && (note.pitch.step == .C || note.pitch.step.toString() == "D" || note.pitch.step.toString() == "F" || note.pitch.step.toString() == "G" || note.pitch.step.toString() == "A"){
            MIDINum += 1
        }

        //Flat handling
        if note.accidental == .flat && (note.pitch.step.toString() == "B" || note.pitch.step.toString() == "E" || note.pitch.step.toString() == "A" || note.pitch.step.toString() == "D" || note.pitch.step.toString() == "G" || note.pitch.step.toString() == "C" || note.pitch.step.toString() == "F"){
            MIDINum -= 1
        }

        if note.accidental == .doubleSharp {
            MIDINum += 2
        }

        return MIDINum + 3
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
                    //print("Note Added. Adding the Trailing 0s")
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
        do {
            /*try AudioKit.stop()
            gNotePlayer.stop()
            fNotePlayer.stop()*/
        } catch let error as NSError{
            print(error.debugDescription)
        }
        EventBroadcaster.instance.postEvent(event: EventNames.STOP_PLAYBACK)
    }
    
    func musicPlayback(_ composition: Composition){
        //self.timer.invalidate()
        
        self.tempo = composition.tempo
        
        self.loadSound()
        
        self.gNotesMIDI = preProcessStaff(staff: composition.staffList[0])
        self.fNotesMIDI = preProcessStaff(staff: composition.staffList[1])

        /*for midi in gNotesMIDI {
            if let m = midi {
                print("MIDI NUMBER: \(m)")
            }
        }*/
        
        do {
            try AudioKit.start()
        } catch let error as NSError{
            print(error.debugDescription)
        }

        self.curBeat = 0

        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 60 / tempo * 0.0625, repeats: true) {_ in
                self.updateTime()
            }
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: 60 / tempo * 0.0625,
                                 target: self,
                                 selector: #selector(self.updateTime),
                                 userInfo: nil,
                                 repeats: true)
        }

        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc
    func updateTime() {
        if !self.gNotesMIDI.isEmpty && self.curBeat < self.gNotesMIDI.count {
            if let noteNumber = self.gNotesMIDI[self.curBeat] {
                self.gNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
            }
        }
        
        if !self.fNotesMIDI.isEmpty && self.curBeat < self.fNotesMIDI.count {
            if let noteNumber = self.fNotesMIDI[self.curBeat] {
                self.fNotePlayer.play(noteNumber: MIDINoteNumber(noteNumber))
            }
        }
        
        self.curBeat += 1
        
        if self.curBeat > self.gNotesMIDI.count + 5 && self.curBeat > self.fNotesMIDI.count + 5 {
            self.stopPlaying()
            self.isPlaying = false
        }
        
        /*if Double(curBeat) > self.tempo * co {
         timer.invalidate()
         }*/
    }
}







