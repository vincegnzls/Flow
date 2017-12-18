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
        dismiss(animated: true) {
            //asd
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
    
    
    // Updates label whenever number of beats is changed
    @IBAction func onChangeBeatDuration(_ sender: UISlider) {
        beatDurationLabel.text = String(Int(sender.value) * 2)
    }
}
