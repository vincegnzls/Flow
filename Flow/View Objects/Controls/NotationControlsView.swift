//
//  NotationControls.swift
//  Flow
//
//  Created by Kevin Chan on 07/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class NotationControlsView: DraggableView {

    override var keyTag: String {
        return "NotationControlsView"
    }
    
    @IBOutlet var wholeNote: UIButton!
    @IBOutlet var wholeRest: UIButton!
    @IBOutlet var halfNote: UIButton!
    @IBOutlet var halfRest: UIButton!
    @IBOutlet var quarterNote: UIButton!
    @IBOutlet var quarterRest: UIButton!
    @IBOutlet var eighthNote: UIButton!
    @IBOutlet var eighthRest: UIButton!
    @IBOutlet var sixteenthNote: UIButton!
    @IBOutlet var sixteenthRest: UIButton!
    @IBOutlet var thirtySecondNote: UIButton!
    @IBOutlet var thirtySecondRest: UIButton!
    @IBOutlet var sixtyFourthNote: UIButton!
    @IBOutlet var sixtyFourthRest: UIButton!
    
    private var keyboardInputOn: Bool
    
    override init(frame: CGRect) {
        self.keyboardInputOn = false
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        self.keyboardInputOn = false
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        // Set up border
        //self.layer.borderWidth = 1.5
        //self.layer.borderColor = UIColor.black.cgColor
        //self.layer.cornerRadius = 10
        
        // Set up shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
        
        
        EventBroadcaster.instance.addObserver(event: EventNames.UPDATE_INVALID_NOTES,
                                              observer: Observer(id: "NotationControls.updateInvalidNotes", function: self.updateInvalidNotes))
        EventBroadcaster.instance.addObserver(event: EventNames.MEASURE_SWITCHED,
                                              observer: Observer(id: "NotationControls.measureSwitched", function: self.measureSwitched))

        EventBroadcaster.instance.removeObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "NotationControls.hideOnPlay", function: self.hideOnPlay))
        EventBroadcaster.instance.addObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "NotationControls.hideOnPlay", function: self.hideOnPlay))

        EventBroadcaster.instance.removeObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "NotationControls.hideOnPlay", function: self.hideOnPlay))
        EventBroadcaster.instance.addObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "NotationControls.hideOnPlay", function: self.hideOnPlay))
        EventBroadcaster.instance.removeObserver(event: EventNames.TOGGLE_KEYBOARD, observer: Observer(id: "NotationControls.toggleKeyboard", function: self.toggleKeyboard))
        EventBroadcaster.instance.addObserver(event: EventNames.TOGGLE_KEYBOARD, observer: Observer(id: "NotationControls.toggleKeyboard", function: self.toggleKeyboard))
    }
    
    @IBAction func wholeNote(_ sender: UIButton) {
        print("WHOLE NOTE")
        
        if self.keyboardInputOn {
            noteKeyboardTapped(noteType: RestNoteType.whole, isRest: false)
            
            self.wholeNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            self.halfNote.backgroundColor = nil
            self.quarterNote.backgroundColor = nil
            self.eighthNote.backgroundColor = nil
            self.sixteenthNote.backgroundColor = nil
            self.thirtySecondNote.backgroundColor = nil
            self.sixtyFourthNote.backgroundColor = nil
            self.wholeRest.backgroundColor = nil
        } else {
            noteKeyTapped(noteType: RestNoteType.whole, isRest: false)
        }
    }
    
    @IBAction func halfNote(_ sender: UIButton) {
        print("HALF NOTE")
       
        if self.keyboardInputOn {
            noteKeyboardTapped(noteType: RestNoteType.half, isRest: false)
            
            self.wholeNote.backgroundColor = nil
            self.halfNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            self.quarterNote.backgroundColor = nil
            self.eighthNote.backgroundColor = nil
            self.sixteenthNote.backgroundColor = nil
            self.thirtySecondNote.backgroundColor = nil
            self.sixtyFourthNote.backgroundColor = nil
        } else {
            noteKeyTapped(noteType: RestNoteType.half, isRest: false)
        }
    }
    
    @IBAction func quarterNote(_ sender: UIButton) {
        print("QUARTER NOTE")
        
        if self.keyboardInputOn {
            noteKeyboardTapped(noteType: RestNoteType.quarter, isRest: false)
            
            self.wholeNote.backgroundColor = nil
            self.halfNote.backgroundColor = nil
            self.quarterNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            self.eighthNote.backgroundColor = nil
            self.sixteenthNote.backgroundColor = nil
            self.thirtySecondNote.backgroundColor = nil
            self.sixtyFourthNote.backgroundColor = nil
        } else {
            noteKeyTapped(noteType: RestNoteType.quarter, isRest: false)
        }
    }
    
    @IBAction func eighthNote(_ sender: UIButton) {
        print("EIGHTH NOTE")
        
        if self.keyboardInputOn {
            noteKeyboardTapped(noteType: RestNoteType.eighth, isRest: false)
            
            self.wholeNote.backgroundColor = nil
            self.halfNote.backgroundColor = nil
            self.quarterNote.backgroundColor = nil
            self.eighthNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            self.sixteenthNote.backgroundColor = nil
            self.thirtySecondNote.backgroundColor = nil
            self.sixtyFourthNote.backgroundColor = nil
        } else {
            noteKeyTapped(noteType: RestNoteType.eighth, isRest: false)
        }
    }
    
    @IBAction func sixteenthNote(_ sender: UIButton) {
        print("SIXTEENTH NOTE")
        
        if self.keyboardInputOn {
            noteKeyboardTapped(noteType: RestNoteType.sixteenth, isRest: false)
            
            self.wholeNote.backgroundColor = nil
            self.halfNote.backgroundColor = nil
            self.quarterNote.backgroundColor = nil
            self.eighthNote.backgroundColor = nil
            self.sixteenthNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            self.thirtySecondNote.backgroundColor = nil
            self.sixtyFourthNote.backgroundColor = nil
        } else {
            noteKeyTapped(noteType: RestNoteType.sixteenth, isRest: false)
        }
    }
    
    @IBAction func thirtySecondNote(_ sender: UIButton) {
        print("THIRTY SECOND NOTE")
        
        if self.keyboardInputOn {
            noteKeyboardTapped(noteType: RestNoteType.thirtySecond, isRest: false)
            
            self.wholeNote.backgroundColor = nil
            self.halfNote.backgroundColor = nil
            self.quarterNote.backgroundColor = nil
            self.eighthNote.backgroundColor = nil
            self.sixteenthNote.backgroundColor = nil
            self.thirtySecondNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            self.sixtyFourthNote.backgroundColor = nil
        } else {
            noteKeyTapped(noteType: RestNoteType.thirtySecond, isRest: false)
        }
    }
    
    @IBAction func sixtyFourthNote(_ sender: UIButton) {
        print("SIXTY FOURTH NOTE")
        
        noteKeyTapped(noteType: RestNoteType.sixtyFourth, isRest: false)
    }
    
    @IBAction func wholeRest(_ sender: UIButton) {
        print("WHOLE NOTE")
        
        noteKeyTapped(noteType: RestNoteType.whole, isRest: true)
    }
    
    @IBAction func halfRest(_ sender: UIButton) {
        print("HALF NOTE")
        
        noteKeyTapped(noteType: RestNoteType.half, isRest: true)
    }
    
    @IBAction func quarterRest(_ sender: UIButton) {
        print("QUARTER NOTE")
        
        noteKeyTapped(noteType: RestNoteType.quarter, isRest: true)
    }
    
    @IBAction func eighthRest(_ sender: UIButton) {
        print("EIGHTH NOTE")
        
        noteKeyTapped(noteType: RestNoteType.eighth, isRest: true)
    }
    
    @IBAction func sixteenthRest(_ sender: UIButton) {
        print("SIXTEENTH NOTE")
        
        noteKeyTapped(noteType: RestNoteType.sixteenth, isRest: true)
    }
    
    @IBAction func thirtySecondRest(_ sender: UIButton) {
        print("THIRTY SECOND NOTE")
        
        noteKeyTapped(noteType: RestNoteType.thirtySecond, isRest: true)
    }
    
    @IBAction func sixtyFourthRest(_ sender: UIButton) {
        print("SIXTY FOURTH NOTE")
        
        noteKeyTapped(noteType: RestNoteType.sixtyFourth, isRest: true)
    }
    
    @IBAction func deleteNote(_ sender: UIButton) {
        print("DELETE")
        deleteKeyTapped()
    }
    
    func deleteKeyTapped() {
        EventBroadcaster.instance.postEvent(event: EventNames.DELETE_KEY_PRESSED)
    }
    
    func noteKeyboardTapped(noteType: RestNoteType, isRest: Bool) {
        let params = Parameters()
        
        params.put(key: KeyNames.NOTE_KEY_TYPE, value: noteType)
        params.put(key: KeyNames.IS_REST_KEY, value: isRest)
        EventBroadcaster.instance.postEvent(event: EventNames.CHANGE_KEYBOARD_INPUT_TYPE, params: params)
    }
    
    func noteKeyTapped(noteType: RestNoteType, isRest: Bool) {
        let params = Parameters()
        
        params.put(key: KeyNames.NOTE_KEY_TYPE, value: noteType)
        params.put(key: KeyNames.IS_REST_KEY, value: isRest)
        EventBroadcaster.instance.postEvent(event: EventNames.NOTATION_KEY_PRESSED, params: params)
    }
    
    func toggleNoteButtons(note: RestNoteType, isEnabled: Bool) {
        if note == RestNoteType.whole {
            wholeNote.isEnabled = isEnabled
            wholeRest.isEnabled = isEnabled
        } else if note == RestNoteType.half {
            halfNote.isEnabled = isEnabled
            halfRest.isEnabled = isEnabled
        } else if note == RestNoteType.quarter {
            quarterNote.isEnabled = isEnabled
            quarterRest.isEnabled = isEnabled
        } else if note == RestNoteType.eighth {
            eighthNote.isEnabled = isEnabled
            eighthRest.isEnabled = isEnabled
        } else if note == RestNoteType.sixteenth {
            sixteenthNote.isEnabled = isEnabled
            sixteenthRest.isEnabled = isEnabled
        } else if note == RestNoteType.thirtySecond {
            thirtySecondNote.isEnabled = isEnabled
            thirtySecondRest.isEnabled = isEnabled
        } else if note == RestNoteType.sixtyFourth {
            sixtyFourthNote.isEnabled = isEnabled
            sixtyFourthRest.isEnabled = isEnabled
        }
    }
    
    func measureSwitched(params: Parameters) {
        let measure:Measure = params.get(key: KeyNames.NEW_MEASURE) as! Measure
        
        measure.updateInvalidNotes(invalidNotes: measure.getInvalidNotes())
    }
    
    func updateInvalidNotes(params: Parameters) {
        let invalidNotes:[RestNoteType] = params.get(key: KeyNames.INVALID_NOTES) as! [RestNoteType]
        
        for note in RestNoteType.types {
            if invalidNotes.contains(note) {
                toggleNoteButtons(note: note, isEnabled: false)
            } else {
                toggleNoteButtons(note: note, isEnabled: true)
            }
        }
    }
    
    public func toggleKeyboard() {
        self.keyboardInputOn = !self.keyboardInputOn
        
        if self.keyboardInputOn {
            self.quarterNote.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
        } else {
            self.wholeNote.backgroundColor = nil
            self.halfNote.backgroundColor = nil
            self.quarterNote.backgroundColor = nil
            self.eighthNote.backgroundColor = nil
            self.sixteenthNote.backgroundColor = nil
            self.thirtySecondNote.backgroundColor = nil
            self.sixtyFourthNote.backgroundColor = nil
        }
    }

    func hideOnPlay() {

        print("wtf")

        if !SoundManager.instance.isPlaying {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
    }

}
