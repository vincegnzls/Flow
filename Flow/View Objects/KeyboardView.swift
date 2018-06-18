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
    
    public var keyboardInputType: RestNoteType
    public var isRest: Bool
    
    override init(frame: CGRect) {
        self.keyboardInputType = .quarter
        self.isRest = false
        super.init(frame: frame)
        self.setup()
        print("INIT KEYBOARD")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.keyboardInputType = .quarter
        self.isRest = false
        super.init(coder: aDecoder)
        self.setup()
        print("INIT KEYBOARD")
    }
    
    private func setup() {
        self.delegate = self
        self.polyphonicMode = true
        self.octaveCount = 7
        self.firstOctave = 0
        self.isHidden = true

        //self.frame = CGRect(x: 0, y: 0, width: 400, height: 100)
        pianoSound.volume = 5.0

        do{
            try pianoSound.loadWav("Support Objects/Grand Piano-tailed")
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
        
        EventBroadcaster.instance.removeObserver(event: EventNames.CHANGE_KEYBOARD_INPUT_TYPE, observer: Observer(id: "NotationControlsView.changeKeyboardInputType", function: self.changeKeyboardInputType))
        EventBroadcaster.instance.addObserver(event: EventNames.CHANGE_KEYBOARD_INPUT_TYPE, observer: Observer(id: "NotationControlsView.changeKeyboardInputType", function: self.changeKeyboardInputType))
    }
    
    func changeKeyboardInputType(params: Parameters) {
        let restNoteType: RestNoteType = params.get(key: KeyNames.NOTE_KEY_TYPE) as! RestNoteType
        let isRest = params.get(key: KeyNames.IS_REST_KEY, defaultValue: false)
        
        self.keyboardInputType = restNoteType
        self.isRest = isRest
    }
    
    func noteOn(note: MIDINoteNumber) {
        //SoundManager.instance.pl
        
        pianoSound.play(noteNumber: note + 3)

        let params = Parameters()
        params.put(key: KeyNames.KEYBOARD_NOTE, value: MIDINoteParser.instance.parse(noteNumber: note, type: self.keyboardInputType))
        params.put(key: KeyNames.IS_REST_KEY, value: self.isRest)

        print("Note Number: \(note) \(self.keyboardInputType) \(self.isRest)")
        EventBroadcaster.instance.postEvent(event: EventNames.KEYBOARD_NOTE_PRESSED, params: params)
    }
    
    func noteOff(note: MIDINoteNumber) {
        //pianoSound.stop(noteNumber: note)
    }
}
