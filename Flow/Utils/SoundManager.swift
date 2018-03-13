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

class SoundManager{
    var tempo: Double
    var staffPlayers: [[AVPlayer]]
    var staffAKPlayers: [[AKAudioPlayer]]

    var player = AVPlayer()
    
    init() {
        tempo = 120
        self.staffPlayers = [[AVPlayer]]()
        self.staffAKPlayers = [[AKAudioPlayer]]()
    }

    func getNoteUrl(note: Note) -> URL? {
        let folderName = "Support Objects/"
        var resName = "a1-mf"

        if note.accidental == .sharp || note.accidental == .doubleSharp {
            note.transposeUp()
        }

        switch note.pitch.step.toString(){
        case "C":
            switch note.pitch.octave{
            case 1: resName = "c1-mf"
            case 2: resName = "c2-mf"
            case 3: resName = "c3-mf"
            case 4: resName = "c4-mf"
            case 5: resName = "c5-mf"
            case 6: resName = "c6-mf"
            case 7: resName = "c7-mf"
            case 8: resName = "c8-mf"
            default:
                resName = "c1-mf"
            }
            break
        case "D":
            switch note.pitch.octave{
            case 1: resName = "d1-mf"
            case 2: resName = "d2-mf"
            case 3: resName = "d3-mf"
            case 4: resName = "d4-mf"
            case 5: resName = "d5-mf"
            case 6: resName = "d6-mf"
            case 7: resName = "d7-mf"
            default:
                resName = "d1-mf"
            }
            break
        case "E":
            switch note.pitch.octave{
            case 1: resName = "e1-mf"
            case 2: resName = "e2-mf"
            case 3: resName = "e3-mf"
            case 4: resName = "e4-mf"
            case 5: resName = "e5-mf"
            case 6: resName = "e6-mf"
            case 7: resName = "e7-mf"
            default:
                resName = "e1-mf"
            }
            break
        case "F":
            switch note.pitch.octave{
            case 1: resName = "f1-mf"
            case 2: resName = "f2-mf"
            case 4: resName = "f4-mf"
            case 5: resName = "f5-mf"
            case 6: resName = "f6-mf"
            case 7: resName = "f7-mf"
            default:
                resName = "f1-mf"
            }
            break
        case "G":
            switch note.pitch.octave{
            case 1: resName = "g1-mf"
            case 2: resName = "g2-mf"
            case 3: resName = "g3-mf"
            case 4: resName = "g4-mf"
            case 5: resName = "g5-mf"
            case 6: resName = "g6-mf"
            case 7: resName = "g7-mf"
            default:
                resName = "g1-mf"
            }
            break
        case "A":
            switch note.pitch.octave{
            case 1: resName = "a1-mf"
            case 2: resName = "a2-mf"
            case 3: resName = "a3-mf"
            case 4: resName = "a4-mf"
            case 5: resName = "a5-mf"
            case 6: resName = "a6-mf"
            case 7: resName = "a7-mf"
            default:
                resName = "a1-mf"
            }
            break
        case "B":
            switch note.pitch.octave{
            case 0: resName = "b0-mf"
            case 1: resName = "b1-mf"
            case 2: resName = "b2-mf"
            case 3: resName = "b3-mf"
            case 4: resName = "b4-mf"
            case 5: resName = "b5-mf"
            case 6: resName = "b6-mf"
            case 7: resName = "b7-mf"
            default:
                resName = "b0-mf"
            }
            break

        default:
            break
        }

        if note.accidental == .sharp || note.accidental == .flat {
            resName.insert("b", at: resName.index(after: resName.startIndex))
        }

        if let url = Bundle.main.url(forResource: folderName + resName, withExtension: "mp3") {
            return url
        } else {
            return nil
        }
    }

    func getNoteFileName(note: Note) -> String {
        var resName = "a1-mf"
        let folderName = "Support Objects/"

        if note.accidental == .sharp || note.accidental == .doubleSharp {
            note.transposeUp()
        }

        switch note.pitch.step.toString(){
        case "C":
            switch note.pitch.octave{
            case 1: resName = "c1-mf"
            case 2: resName = "c2-mf"
            case 3: resName = "c3-mf"
            case 4: resName = "c4-mf"
            case 5: resName = "c5-mf"
            case 6: resName = "c6-mf"
            case 7: resName = "c7-mf"
            case 8: resName = "c8-mf"
            default:
                resName = "c1-mf"
            }
            break
        case "D":
            switch note.pitch.octave{
            case 1: resName = "d1-mf"
            case 2: resName = "d2-mf"
            case 3: resName = "d3-mf"
            case 4: resName = "d4-mf"
            case 5: resName = "d5-mf"
            case 6: resName = "d6-mf"
            case 7: resName = "d7-mf"
            default:
                resName = "d1-mf"
            }
            break
        case "E":
            switch note.pitch.octave{
            case 1: resName = "e1-mf"
            case 2: resName = "e2-mf"
            case 3: resName = "e3-mf"
            case 4: resName = "e4-mf"
            case 5: resName = "e5-mf"
            case 6: resName = "e6-mf"
            case 7: resName = "e7-mf"
            default:
                resName = "e1-mf"
            }
            break
        case "F":
            switch note.pitch.octave{
            case 1: resName = "f1-mf"
            case 2: resName = "f2-mf"
            case 4: resName = "f4-mf"
            case 5: resName = "f5-mf"
            case 6: resName = "f6-mf"
            case 7: resName = "f7-mf"
            default:
                resName = "f1-mf"
            }
            break
        case "G":
            switch note.pitch.octave{
            case 1: resName = "g1-mf"
            case 2: resName = "g2-mf"
            case 3: resName = "g3-mf"
            case 4: resName = "g4-mf"
            case 5: resName = "g5-mf"
            case 6: resName = "g6-mf"
            case 7: resName = "g7-mf"
            default:
                resName = "g1-mf"
            }
            break
        case "A":
            switch note.pitch.octave{
            case 1: resName = "a1-mf"
            case 2: resName = "a2-mf"
            case 3: resName = "a3-mf"
            case 4: resName = "a4-mf"
            case 5: resName = "a5-mf"
            case 6: resName = "a6-mf"
            case 7: resName = "a7-mf"
            default:
                resName = "a1-mf"
            }
            break
        case "B":
            switch note.pitch.octave{
            case 0: resName = "b0-mf"
            case 1: resName = "b1-mf"
            case 2: resName = "b2-mf"
            case 3: resName = "b3-mf"
            case 4: resName = "b4-mf"
            case 5: resName = "b5-mf"
            case 6: resName = "b6-mf"
            case 7: resName = "b7-mf"
            default:
                resName = "b0-mf"
            }
            break

        default:
            break
        }

        if note.accidental == .sharp || note.accidental == .flat {
            resName.insert("b", at: resName.index(after: resName.startIndex))
        }

        return folderName + resName + ".mp3"
    }

    /*func playNote(note: Note) {
        if let url = getNoteUrl(note: note) {
            print("ADD NOTE URL: \(url)")

            self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
            self.player.play()

        }
    }*/

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
    
    func getNoteDurationInSeconds(note: Note) -> Double {

        let playTime: Double
        
        switch note.type.toString(){
        case "64th": playTime = 60 / tempo * 0.0625
        case "32nd" : playTime = 60 / tempo * 0.125
        case "16th" : playTime = 60 / tempo * 0.25
        case "eigth" : playTime = 60 / tempo * 0.5
        case "quarter" : playTime = 60 / tempo
        case "half" : playTime = 60 / tempo * 2
        case "whole" : playTime = 60 / tempo * 4
        default:
            playTime = 60 / tempo
            break
        }

        return playTime

        
        /*if let url = Bundle.main.url(forResource: folderName + resName, withExtension: "mp3") {
            print(url.absoluteString)
            playTimes.append(playTime)
            players.append(AVPlayer(playerItem: AVPlayerItem(url: url)))
        }*/
        
        /*do{
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.prepareToPlay()
            audioPlayer.currentTime = 0.5
        }catch let error as NSError{
            print(error.debugDescription)
        }
        
        audioPlayer.play()
        
        print("playTime is: \(playTime)" )
        
        if #available(iOS 10.0, *) {
            print("Timer is ticking")
            Timer.scheduledTimer(withTimeInterval: playTime/1000, repeats: false){
                (timer) in self.audioPlayer.stop()
                print("Stopping Audio Player")
            }
        } else {
            print("Nothing happened")
            // Fallback on earlier versions
        }*/
    }

    func getStaffPlayer(staff: Staff) -> [AVPlayer] {
        var staffPlayer = [AVPlayer]()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                if let note = notation as? Note {
                    if let url = getNoteUrl(note: note) {
                        print(url.absoluteString)
                        staffPlayer.append(AVPlayer(playerItem: AVPlayerItem(url: url)))
                        print("player: \(staffPlayer.count)")
                    }
                }
            }
        }

        return staffPlayer
    }

    func getStaffAKPlayer(staff: Staff) -> [AKAudioPlayer] {
        var staffPlayer = [AKAudioPlayer]()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                if let note = notation as? Note {
                    staffPlayer.append(try! AKAudioPlayer(file: try! AKAudioFile(readFileName: getNoteFileName(note: note))))
                    print("player: \(staffPlayer.count)")
                }
            }
        }

        return staffPlayer
    }

    func getStaffNoteDurations(staff: Staff) -> [Double] {
        var noteDurations = [Double]()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                if let note = notation as? Note {
                    noteDurations.append(getNoteDurationInSeconds(note: note))
                }
            }
        }

        return noteDurations
    }

    /*func initStaffPlayers(staffList: [Staff]) {
        self.staffPlayers.removeAll()

        for staff in staffList {
            self.staffPlayers.append(getStaffPlayer(staff: staff))
        }
    }

    func initStaffNoteDurations(staffList: [Staff]) {
        self.staffNoteDurations.removeAll()

        for staff in staffList {
            self.staffNoteDurations.append(getStaffNoteDurations(staff: staff))
        }
    }*/

    /*func preProcessStaff(staff:Staff) -> AKAudioPlayer {
        let oneSixteenthLength = Int64(3.42 * 44_100)

        print(oneSixteenthLength)

        var curNoteFile: AKAudioFile
        var sequence = try! AKAudioFile()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                if let note = notation as? Note {
                    print(getNoteFileName(note: note))
                    curNoteFile = try! AKAudioFile(readFileName: getNoteFileName(note: note))

                    let curFixedNoteFile = try! curNoteFile.extracted(fromSample: 0, toSample: oneSixteenthLength / 8)

                    var newFile = try! sequence.appendedBy(file: curFixedNoteFile)

                    sequence = newFile
                }
            }
        }

        let sequencePlayer = try! AKAudioPlayer(file: sequence)

        return sequencePlayer
    }*/

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
                    if let noteUrl = getNoteUrl(note: note) {
                        notePlayer.append(getNoteMIDINum(note: note))
                    }
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

    func playStaff (staff: Staff, staffPlayer: [AVPlayer]) {
        let staffNoteDurations = getStaffNoteDurations(staff: staff)

        var curDuration: Double = 0

        for (duration, player) in zip(staffNoteDurations, staffPlayer) {
            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: curDuration, repeats: false){ _ in
                    player.play()
                }

                curDuration = curDuration + duration
                print("curDuration: \(curDuration)")
            }
        }
    }
    
    func musicPlayback(_ composition: Composition){
        /*staffPlayers.removeAll()

        for staff in composition.staffList {
            staffPlayers.append(getStaffPlayer(staff: staff))
        }

        for (staff, staffPlayer) in zip(composition.staffList, staffPlayers) {
            if #available(iOS 10.0, *) {

                Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { _ in
                    self.playStaff(staff: composition.staffList[0], staffPlayer: self.staffPlayers[0])
                }

                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    self.playStaff(staff: composition.staffList[1], staffPlayer: self.staffPlayers[1])
                }

                /*let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
                concurrentQueue.sync {
                    self.playStaff(staff: staff, staffPlayer: staffPlayer)
                }*/

            }

        }

        staffAKPlayers.removeAll()

        for staff in composition.staffList {
            staffAKPlayers.append(getStaffAKPlayer(staff: staff))
        }

        for staff in staffAKPlayers {
            print("STAFF AK PLAYERS COUNT: \(staff.count)")
        }

        var curParallelPlayers = [[AKAudioPlayer]]()

        for (staffPlayer, i) in zip(self.staffAKPlayers, 0...self.staffAKPlayers.count) {

            for (player, j) in zip(staffPlayer, 0...staffPlayer.count) {
                if staffPlayer.count > curParallelPlayers.count || i == 0 {
                    var curArray = [AKAudioPlayer]()
                    curArray.append(player)
                    curParallelPlayers.append(curArray)
                } else {
                    print("HEEH \(j)")
                    print("CUR PARALLEL PLAYERS COUNT \(curParallelPlayers.count)")
                    if j < curParallelPlayers.count {
                        curParallelPlayers[j].append(player)
                    }
                }
            }
        }

        for parallel in curParallelPlayers {
            let mixer = AKMixer()

            for node in parallel {
                mixer.connect(node)
            }

            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
                    AudioKit.output = mixer
                    try! AudioKit.start()

                    for node in parallel {
                        node.start()
                    }
                }

            }
        }
        
        if #available(iOS 10.0, *) {
            
            Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
                let player = self.preProcessStaff(staff: composition.staffList[0])
                
                AudioKit.output = player
                
                try! AudioKit.start()
                
                player.play()
            }
            
        }*/
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

        var timer = Timer()

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

                /*if Double(curBeat) > self.tempo * co {
                    timer.invalidate()
                }*/
            }
        }

    }
}







