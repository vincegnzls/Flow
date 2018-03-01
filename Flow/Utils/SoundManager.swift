//
//  SoundManager.swift
//  Flow
//
//  Created by Kevin Chan AND MIGO DANCEL on 03/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager{
    var url = Bundle.main.url(forResource: "a1-mf", withExtension: "mp3")
    
    var audioPlayer:AVAudioPlayer!
    
    var resName = "a1-mf"
    
    var playTime = 1000.0
    
    func playSound(_ note: Note){
        
        switch note.type.toString(){
        case "64th": playTime = 75.0
        case "32nd" : playTime = 125.0
        case "16th" : playTime = 250.0
        case "eigth" : playTime = 500.0
        case "quarter" : playTime = 1000.0
        case "half" : playTime = 2000.0
        case "whole" : playTime = 4000.0
        default:
            playTime = 1000.0
            break
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
        
        url = Bundle.main.url(forResource: resName, withExtension: "mp3")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.prepareToPlay()
            audioPlayer.currentTime = 0
        }catch let error as NSError{            print(error.debugDescription)
        }
        
        audioPlayer.play()
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: playTime, repeats: false){
                (timer) in self.audioPlayer.stop()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func musicPlayback(_ composition: Composition){
        for staff in composition.staffList{
            for measure in staff.measures{
                for musicNotation in measure.notationObjects{
                    if(musicNotation.type == Note){
                        playSound(musicNotation)
                    }
                }
            }
        }
        
    }
}


        




