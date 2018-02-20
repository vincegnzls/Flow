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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeySignaturePicker()

        if let measure = GridSystem.instance.getCurrentMeasure() {
            nBeatsLabel.text = String(measure.timeSignature.beats)
            beatDurationLabel.text = String(measure.timeSignature.beatType)
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
        let newMaxBeatValue: Float = Float(self.nBeatsLabel!.text!)! / Float(self.beatDurationLabel!.text!)!

        if let measure = GridSystem.instance.getCurrentMeasure() {
            if newMaxBeatValue >= measure.getTotalBeats() {
                dismiss(animated: true) {
                    let params:Parameters = Parameters()
                    params.put(key: KeyNames.OLD_MEASURE, value: measure)

                    var newMeasure = Measure()

                    newMeasure.timeSignature.beats = Int(self.nBeatsLabel!.text!)!
                    newMeasure.timeSignature.beatType = Int(self.beatDurationLabel!.text!)!

                    params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)

                    EventBroadcaster.instance.postEvent(event: EventNames.EDIT_TIME_SIG, params: params)

                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                }
            } else {
                let alert = UIAlertController(title: "Invalid Time Signature", message: "Changing the time signature would cut off some of your notes. Do you want to proceed?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Proceed", style: .destructive) { _ in
                    if let measure = GridSystem.instance.getCurrentMeasure() {

                        var measures = [Measure]()
                        var notes = [MusicNotation]()

                        //var curMeasureTotalBeats = measure.getTotalBeats()

                        while newMaxBeatValue < measure.getTotalBeats() {
                            /*measures.append(measure)
                            notes.append(measure.notationObjects[measure.notationObjects.count - 1])
                            curMeasureTotalBeats = curMeasureTotalBeats - measure.notationObjects[measure.notationObjects.count - 1].type.getBeatValue()*/
                            measure.deleteInMeasure(measure.notationObjects[measure.notationObjects.count - 1])
                        }
                        
                        self.dismiss(animated: true) {
                            measure.timeSignature.beats = Int(self.nBeatsLabel!.text!)!
                            measure.timeSignature.beatType = Int(self.beatDurationLabel!.text!)!

                            let params:Parameters = Parameters()
                            params.put(key: KeyNames.NEW_MEASURE, value: measure)

                            EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                            EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                        }

                        /*let delAction = DeleteAction(measures: measures, notes: notes)
                        delAction.execute()*/
                    }
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in

                })

                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    // When a user taps cancel
    @IBAction func onCancelPress(_ sender: Any) {
        dismiss(animated: true) {
            //asd
        }
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
