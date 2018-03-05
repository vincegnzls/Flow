//
//  NotationControls.swift
//  Flow
//
//  Created by Kevin Chan on 07/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class NotationControlsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        // Set up border
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.black.cgColor
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
    }
    
    @IBAction func wholeNote(_ sender: ButtonEffect) {
        print("WHOLE NOTE")
        noteKeyTapped(noteType: RestNoteType.whole, isRest: false)
    }
    
    @IBAction func halfNote(_ sender: ButtonEffect) {
        print("HALF NOTE")
        noteKeyTapped(noteType: RestNoteType.half, isRest: false)
    }
    
    @IBAction func quarterNote(_ sender: ButtonEffect) {
        print("QUARTER NOTE")
        noteKeyTapped(noteType: RestNoteType.quarter, isRest: false)
    }
    
    @IBAction func eighthNote(_ sender: ButtonEffect) {
        print("EIGHTH NOTE")
        noteKeyTapped(noteType: RestNoteType.eighth, isRest: false)
    }
    
    @IBAction func sixteenthNote(_ sender: ButtonEffect) {
        print("SIXTEENTH NOTE")
        noteKeyTapped(noteType: RestNoteType.sixteenth, isRest: false)
    }
    
    @IBAction func thirtySecondNote(_ sender: ButtonEffect) {
        print("THIRTY SECOND NOTE")
        noteKeyTapped(noteType: RestNoteType.thirtySecond, isRest: false)
    }
    
    @IBAction func sixtyFourthNote(_ sender: ButtonEffect) {
        print("SIXTY FOURTH NOTE")
        noteKeyTapped(noteType: RestNoteType.sixtyFourth, isRest: false)
    }
    
    @IBAction func wholeRest(_ sender: ButtonEffect) {
        print("WHOLE NOTE")
        noteKeyTapped(noteType: RestNoteType.whole, isRest: true)
    }
    
    @IBAction func halfRest(_ sender: ButtonEffect) {
        print("HALF NOTE")
        noteKeyTapped(noteType: RestNoteType.half, isRest: true)
    }
    
    @IBAction func quarterRest(_ sender: ButtonEffect) {
        print("QUARTER NOTE")
        noteKeyTapped(noteType: RestNoteType.quarter, isRest: true)
    }
    
    @IBAction func eighthRest(_ sender: ButtonEffect) {
        print("EIGHTH NOTE")
        noteKeyTapped(noteType: RestNoteType.eighth, isRest: true)
    }
    
    @IBAction func sixteenthRest(_ sender: ButtonEffect) {
        print("SIXTEENTH NOTE")
        noteKeyTapped(noteType: RestNoteType.sixteenth, isRest: true)
    }
    
    @IBAction func thirtySecondRest(_ sender: ButtonEffect) {
        print("THIRTY SECOND NOTE")
        noteKeyTapped(noteType: RestNoteType.thirtySecond, isRest: true)
    }
    
    @IBAction func sixtyFourthRest(_ sender: ButtonEffect) {
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
    
}
