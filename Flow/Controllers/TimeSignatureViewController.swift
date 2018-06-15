//
//  TimeSignatureViewController.swift
//  Flow
//
//  Created by Vince on 17/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class TimeSignatureViewController: UIViewController {
    
    @IBOutlet weak var cBtn: KeySignatureButton!
    @IBOutlet weak var gBtn: KeySignatureButton!
    @IBOutlet weak var dBtn: KeySignatureButton!
    @IBOutlet weak var aBtn: KeySignatureButton!
    @IBOutlet weak var eBtn: KeySignatureButton!
    @IBOutlet weak var bBtn: KeySignatureButton!
    @IBOutlet weak var fSharpBtn: KeySignatureButton!
    @IBOutlet weak var cSharpBtn: KeySignatureButton!
    @IBOutlet weak var cFlatBtn: KeySignatureButton!
    @IBOutlet weak var gFlatBtn: KeySignatureButton!
    @IBOutlet weak var dFlatBtn: KeySignatureButton!
    @IBOutlet weak var aFlatBtn: KeySignatureButton!
    @IBOutlet weak var eFlatBtn: KeySignatureButton!
    @IBOutlet weak var bFlatBtn: KeySignatureButton!
    @IBOutlet weak var fBtn: KeySignatureButton!
    
    @IBOutlet weak var nBeatsTextField: UITextField!
    @IBOutlet weak var beatDurationTextField: UITextField!
    
    var nBeatsTextFieldDelegate: UITextFieldDelegate = NBeatsTextFieldDelegate()
    var beatDurationTextFieldDelegate: UITextFieldDelegate = BeatDurationTextFieldDelegate()
    
    //let keySignatureHandler = KeySignaturePicker()
    var rotationAngle: CGFloat = 0
    var valid: Bool = true
    var selectedKeySignature: KeySignature = .c
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTimeSignature()
        
        EventBroadcaster.instance.addObserver(event: EventNames.SELECT_KEY_SIGNATURE,
                                              observer: Observer(id: "TimeSignatureViewController.selectKeySignature", function: self.selectKeySignature))
        
        setupKeySignaturePicker()

        if let measure = GridSystem.instance.getCurrentMeasure() {
            nBeatsTextField.text = String(measure.timeSignature.beats)
            beatDurationTextField.text = String(measure.timeSignature.beatType)

            self.selectedKeySignature = measure.keySignature
            
            let params = Parameters()
            
            params.put(key: KeyNames.SELECTED_KEY_SIG, value: self.selectedKeySignature)
            EventBroadcaster.instance.postEvent(event: EventNames.SELECT_KEY_SIGNATURE, params: params)
        }
    }
    
    func selectKeySignature(params: Parameters) {
        let keySig: KeySignature = params.get(key: KeyNames.SELECTED_KEY_SIG) as! KeySignature
        
        self.selectedKeySignature = keySig
        
        print("KEY SIG: \(self.selectedKeySignature)")
    }
    
    func setupTimeSignature() {
        self.nBeatsTextField.delegate = nBeatsTextFieldDelegate
        self.nBeatsTextField.borderStyle = UITextBorderStyle.roundedRect
        self.beatDurationTextField.delegate = beatDurationTextFieldDelegate
        self.beatDurationTextField.borderStyle = UITextBorderStyle.roundedRect
    }
    
    func setupKeySignaturePicker() {
        // Get data
        //keySignatureHandler.keySignatures = KeySignatureData.getData()
        
        // Rotate picker for horizontal view
        /*rotationAngle = -90 * (.pi / 180)
        keySignaturePicker.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        // Assign delegate and data source
        keySignaturePicker.delegate = keySignatureHandler
        keySignaturePicker.dataSource = keySignatureHandler*/
        cBtn.keySignature = .c
        gBtn.keySignature = .g
        dBtn.keySignature = .d
        aBtn.keySignature = .a
        eBtn.keySignature = .e
        bBtn.keySignature = .b
        fSharpBtn.keySignature = .fSharp
        cSharpBtn.keySignature = .cSharp
        cFlatBtn.keySignature = .cFlat
        gFlatBtn.keySignature = .gFlat
        dFlatBtn.keySignature = .dFlat
        aFlatBtn.keySignature = .aFlat
        eFlatBtn.keySignature = .eFlat
        bFlatBtn.keySignature = .bFlat
        fBtn.keySignature = .f
        
    }

    // When a user taps outside the popup
    @IBAction func onDismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // When a user taps save
    @IBAction func onSavePress(_ sender: Any) {
        if let measure = GridSystem.instance.getCurrentMeasure() {
            /*let newMeasure = Measure(loading: false)

            newMeasure.notationObjects = measure.notationObjects
            newMeasure.keySignature = measure.keySignature

            if let newNBeats = self.nBeatsTextField.text {
                if let newNBeatsInt = Int(newNBeats) {
                    newMeasure.timeSignature.beats = newNBeatsInt
                }
            }
            
            if let newBeatType = self.beatDurationTextField.text {
                if let newBeatTypeInt = Int(newBeatType) {
                    newMeasure.timeSignature.beatType = newBeatTypeInt
                }
            }

            let params:Parameters = Parameters()

            params.put(key: KeyNames.OLD_MEASURE, value: measure)
            params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)

            if self.selectedKeySignature != measure.keySignature {

                newMeasure.keySignature = self.selectedKeySignature
                EventBroadcaster.instance.postEvent(event: EventNames.EDIT_KEY_SIG, params: params)
                EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
            }

            if !sameTimeSignature(t1: measure.timeSignature, t2: newMeasure.timeSignature) {
                let alert = UIAlertController(title: "Time Signature Warning", message: "Changing the time signature may cut off some of your notes. Do you want to proceed?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Proceed", style: .destructive) { _ in
                    self.dismiss(animated: true) {
                        EventBroadcaster.instance.postEvent(event: EventNames.EDIT_TIME_SIG, params: params)
                        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                    }
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in

                })

                self.present(alert, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }*/
            
            // Key Signature
            let oldKeySignature = measure.keySignature
            let newKeySignature = self.selectedKeySignature
            
            // Time Signature
            var newTimeSignature = TimeSignature()
            
            if let newNBeats = self.nBeatsTextField.text {
                if let newNBeatsInt = Int(newNBeats) {
                    newTimeSignature.beats = newNBeatsInt
                }
            }
            
            if let newBeatType = self.beatDurationTextField.text {
                if let newBeatTypeInt = Int(newBeatType) {
                    newTimeSignature.beatType = newBeatTypeInt
                }
            }
            
            let oldTimeSignature = measure.timeSignature
            
            if newTimeSignature.beats < oldTimeSignature.beats {
                let alert = UIAlertController(title: "Warning!", message: "Changing the time signature may cut off some of your notes. Do you want to proceed?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Proceed", style: .destructive) { _ in
                    self.dismiss(animated: true) {
                        self.changeSignature(start: measure,
                                             oldKeySignature: oldKeySignature,
                                             newKeySignature: newKeySignature,
                                             oldTimeSignature: oldTimeSignature,
                                             newTimeSignature: newTimeSignature)
                    }
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    
                })
                
                self.present(alert, animated: true, completion: nil)
            } else if !sameTimeSignature(t1: oldTimeSignature, t2: newTimeSignature) ||
                oldKeySignature != newKeySignature {
                
                self.changeSignature(start: measure,
                                     oldKeySignature: oldKeySignature,
                                     newKeySignature: newKeySignature,
                                     oldTimeSignature: oldTimeSignature,
                                     newTimeSignature: newTimeSignature)
                
                self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
            
        }
    }
    
    private func changeSignature(start: Measure, oldKeySignature: KeySignature, newKeySignature: KeySignature,
                                 oldTimeSignature: TimeSignature, newTimeSignature: TimeSignature) {

        let params:Parameters = Parameters()
        
        params.put(key: KeyNames.START_MEASURE, value: start)
        params.put(key: KeyNames.OLD_KEY_SIGNATURE, value: oldKeySignature)
        params.put(key: KeyNames.NEW_KEY_SIGNATURE, value: newKeySignature)
        params.put(key: KeyNames.OLD_TIME_SIGNATURE, value: oldTimeSignature)
        params.put(key: KeyNames.NEW_TIME_SIGNATURE, value: newTimeSignature)

        EventBroadcaster.instance.postEvent(event: EventNames.EDIT_SIGNATURE, params: params)
    }

    public func sameTimeSignature(t1: TimeSignature, t2: TimeSignature) -> Bool {
        if t1.beats == t2.beats && t1.beatType == t2.beatType {
            return true
        }

        return false
    }
    
    // When a user taps cancel
    @IBAction func onCancelPress(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Updates label whenever number of beats is changed
    @IBAction func onChangeNBeats(_ sender: UISlider) {
        //nBeatsLabel.text = String(Int(sender.value))
    }
    
    
    // Updates label whenever beat duration is changed
    @IBAction func onChangeBeatDuration(_ sender: UISlider) {
        //beatDurationLabel.text = String(Int(sender.value) * 2)
    }
    
    @IBAction func onNBeatsEdit(_ sender: UITextField) {
        if let nBeatsText = sender.text {
            if let nBeatsInt = Int(nBeatsText) {
                if nBeatsInt < 1 {
                    self.nBeatsTextField.text = "1"
                } else if nBeatsInt > 100 {
                    self.nBeatsTextField.text = "100"
                }
            }
        }
    }
    
    @IBAction func onBeatDurationEndEdit(_ sender: UITextField) {
        if let beatDuration = sender.text {
            print(beatDuration)
            if let beatDurationDouble = Double(beatDuration) {
                if beatDurationDouble < 1 {
                    self.beatDurationTextField.text = "1"
                } else if beatDurationDouble > 64 {
                    self.beatDurationTextField.text = "64"
                } else {
                    let round = pow(2, log2(beatDurationDouble).rounded(.down))
                    self.beatDurationTextField.text = String(Int(round))
                }
            }
        }
    }
    
    @IBAction func twoFourPress(_ sender: UIButton) {
        self.nBeatsTextField.text = "2"
        self.beatDurationTextField.text = "4"
    }
    
    @IBAction func threeFourPress(_ sender: UIButton) {
        self.nBeatsTextField.text = "3"
        self.beatDurationTextField.text = "4"
    }
    
    @IBAction func fourFourPress(_ sender: UIButton) {
        self.nBeatsTextField.text = "4"
        self.beatDurationTextField.text = "4"
    }
    
    @IBAction func sixEighthPress(_ sender: UIButton) {
        self.nBeatsTextField.text = "6"
        self.beatDurationTextField.text = "8"
    }
    
}
