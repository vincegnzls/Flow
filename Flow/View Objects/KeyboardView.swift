//
//  KeyboardView.swift
//  Flow
//
//  Created by Vince on 06/05/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit
import AudioKitUI
import AudioKit

class KeyboardView: AKKeyboardView, AKKeyboardDelegate {
    
    //static let instance = KeyboardView()
    
    //public var keyboard = AKKeyboardView(width: 440, height: 100)
    
    //let bank = AKOscillatorBank()
    let pianoSound = AKSampler()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        print("INIT KEYBOARD")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        print("INIT KEYBOARD")
    }
    
    private func setup() {
        self.delegate = self
        self.polyphonicMode = true
        self.octaveCount = 7
        self.firstOctave = 0

        //self.frame = CGRect(x: 0, y: 0, width: 400, height: 100)
        pianoSound.volume = 5.0

        do{
            try pianoSound.loadWav("Support Objects/Grand Piano")
            print("WAV Loaded")
        }catch{
            AKLog("File not found")
            return
        }
        
        AudioKit.output = pianoSound
        
        do {
            try AudioKit.start()
        } catch let error as NSError{
            print(error.debugDescription)
        }
    }
    
    func noteOn(note: MIDINoteNumber) {
        //SoundManager.instance.pl
        print("Note Number: \(note)")
        pianoSound.play(noteNumber: note + 3)
    }
    
    func noteOff(note: MIDINoteNumber) {
        //pianoSound.stop(noteNumber: note)
    }
}
