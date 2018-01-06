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
        
        EventBroadcaster.instance.addObserver(event: EventNames.UPDATE_VALID_NOTES,
                                              observer: Observer(id: "NotationControls.updateValidNotes", function: self.updateValidNotes))
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
    
    func updateValidNotes(params: Parameters) {
        let validNotes:[MusicNotation] = params.get(key: KeyNames.VALID_NOTES) as! [MusicNotation]
        
        for note in validNotes {
            
            if note.valid {
                if note.type == RestNoteType.whole {
                    wholeNote.isEnabled = true
                    wholeRest.isEnabled = true
                } else if note.type == RestNoteType.half {
                    halfNote.isEnabled = true
                    halfRest.isEnabled = true
                } else if note.type == RestNoteType.quarter {
                    quarterNote.isEnabled = true
                    quarterRest.isEnabled = true
                } else if note.type == RestNoteType.eighth {
                    eighthNote.isEnabled = true
                    eighthRest.isEnabled = true
                } else if note.type == RestNoteType.sixteenth {
                    sixteenthNote.isEnabled = true
                    sixteenthRest.isEnabled = true
                } else if note.type == RestNoteType.thirtySecond {
                    thirtySecondNote.isEnabled = true
                    thirtySecondRest.isEnabled = true
                } else if note.type == RestNoteType.sixtyFourth {
                    sixtyFourthNote.isEnabled = true
                    sixtyFourthRest.isEnabled = true
                }
            } else {
                if note.type == RestNoteType.whole {
                    wholeNote.isEnabled = false
                    wholeRest.isEnabled = false
                } else if note.type == RestNoteType.half {
                    halfNote.isEnabled = false
                    halfRest.isEnabled = false
                } else if note.type == RestNoteType.quarter {
                    quarterNote.isEnabled = false
                    quarterRest.isEnabled = false
                } else if note.type == RestNoteType.eighth {
                    eighthNote.isEnabled = false
                    eighthRest.isEnabled = false
                } else if note.type == RestNoteType.sixteenth {
                    sixteenthNote.isEnabled = false
                    sixteenthRest.isEnabled = false
                } else if note.type == RestNoteType.thirtySecond {
                    thirtySecondNote.isEnabled = false
                    thirtySecondRest.isEnabled = false
                } else if note.type == RestNoteType.sixtyFourth {
                    sixtyFourthNote.isEnabled = false
                    sixtyFourthRest.isEnabled = false
                }
            }
            
        }
    }
    
}
