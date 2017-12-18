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
        
        keySignatureHandler.keySignatures = KeySignatureData.getData()
        
        rotationAngle = -90 * (.pi / 180)
        
        keySignaturePicker.transform = CGAffineTransform(rotationAngle: rotationAngle)

        keySignaturePicker.delegate = keySignatureHandler
        keySignaturePicker.dataSource = keySignatureHandler
    }

    @IBAction func onDismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSavePress(_ sender: Any) {
        dismiss(animated: true) {
            //asd
        }
    }
    
    @IBAction func onCancelPress(_ sender: Any) {
        dismiss(animated: true) {
            //asd
        }
    }
    
    @IBAction func onChangeNBeats(_ sender: UISlider) {
        nBeatsLabel.text = String(Int(sender.value))
    }
    
    @IBAction func onChangeBeatDuration(_ sender: UISlider) {
        beatDurationLabel.text = String(Int(sender.value) * 2)
    }
}
