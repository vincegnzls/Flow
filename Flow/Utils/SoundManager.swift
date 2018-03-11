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

class SoundManager{
    let folderName = "Support Objects/"
    var url = Bundle.main.url(forResource: "a1-mf", withExtension: "mp3")

    var tempo: Double
    var staffPlayer: [AVPlayer]
    var staffPlayers: [[AVPlayer]]

    var player = AVPlayer()
    
    init() {
        tempo = 120
        self.staffPlayer = [AVPlayer]()
        self.staffPlayers = [[AVPlayer]]()
    }
    
    var audioPlayer:AVAudioPlayer!
    
    var resName = "a1-mf"

    func getNoteUrl(note: Note) -> URL? {

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

    func playNote(note: Note) {
        if let url = getNoteUrl(note: note) {
            print("ADD NOTE URL: \(url)")

            self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
            self.player.play()

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
        var staffPLayer = [AVPlayer]()
        staffPlayer.removeAll()

        for measure in staff.measures {
            for notation in measure.notationObjects {
                if let note = notation as? Note {
                    if let url = getNoteUrl(note: note) {
                        print(url.absoluteString)
                        self.staffPlayer.append(AVPlayer(playerItem: AVPlayerItem(url: url)))
                        print("player: \(self.staffPlayer.count)")
                    }
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
        staffPlayers.removeAll()

        for staff in composition.staffList {
            staffPlayers.append(getStaffPlayer(staff: staff))
        }

        for (staff, staffPlayer) in zip(composition.staffList, staffPlayers) {
            if #available(iOS 10.0, *) {

                Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
                    self.playStaff(staff: staff, staffPlayer: staffPlayer)
                }

            }

        }
    }
}


        




