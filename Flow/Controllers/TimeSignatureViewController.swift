//
//  TimeSignatureViewController.swift
//  Flow
//
//  Created by Vince on 17/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class TimeSignatureViewController: UIViewController {

    @IBOutlet weak var nBeatsLabel: UILabel!
    @IBOutlet weak var beatDurationLabel: UILabel!
    @IBOutlet weak var keySignaturePicker: UIPickerView!
    
    let keySignatureHandler = KeySignaturePicker()
    var rotationAngle: CGFloat = 0
    var valid: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeySignaturePicker()

        if let measure = GridSystem.instance.getCurrentMeasure() {
            nBeatsLabel.text = String(measure.timeSignature.beats)
            beatDurationLabel.text = String(measure.timeSignature.beatType)

            keySignatureHandler.selectedKeySignature = measure.keySignature
            keySignaturePicker.selectRow(KeySignatureData.getIndexOf(ks: measure.keySignature), inComponent: 0, animated: false)
        }
    }
    
    func setupKeySignaturePicker() {
        // Get data
        keySignatureHandler.keySignatures = KeySignatureData.getData()
        
        // Rotate picker for horizontal view
        rotationAngle = -90 * (.pi / 180)
        keySignaturePicker.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        // Assign delegate and data source
        keySignaturePicker.delegate = keySignatureHandler
        keySignaturePicker.dataSource = keySignatureHandler

    }

    // When a user taps outside the popup
    @IBAction func onDismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // When a user taps save
    @IBAction func onSavePress(_ sender: Any) {
        if let measure = GridSystem.instance.getCurrentMeasure() {
            let newMeasure = Measure(loading: false)

            newMeasure.notationObjects = measure.notationObjects
            newMeasure.keySignature = measure.keySignature

            newMeasure.timeSignature.beats = Int(self.nBeatsLabel!.text!)!
            newMeasure.timeSignature.beatType = Int(self.beatDurationLabel!.text!)!

            let params:Parameters = Parameters()

            params.put(key: KeyNames.OLD_MEASURE, value: measure)
            params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)

            if keySignatureHandler.selectedKeySignature != measure.keySignature {

                newMeasure.keySignature = keySignatureHandler.selectedKeySignature
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
            }


        }
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
        nBeatsLabel.text = String(Int(sender.value))
    }
    
    
    // Updates label whenever beat duration is changed
    @IBAction func onChangeBeatDuration(_ sender: UISlider) {
        beatDurationLabel.text = String(Int(sender.value) * 2)
    }
}
