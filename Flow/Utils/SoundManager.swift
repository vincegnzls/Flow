//
//  SoundManager.swift
//  Flow
//
//  Created by Kevin Chan on 03/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation
import AVFoundation

var url = Bundle.main.url(forResource: "a1-mf", withExtension: "mp3")
    
var audioPlayer:AVAudioPlayer!
    
func playSound(pitch: String, length: String){
    url = Bundle.main.url(forResource: pitch, withExtension: "mp3")
        
    do{
        audioPlayer = try AVAudioPlayer(contentsOf: url!)
        audioPlayer.prepareToPlay()
        audioPlayer.currentTime = 0
    }catch let error as NSError{            print(error.debugDescription)
    }
    
    audioPlayer.play()
}
        




