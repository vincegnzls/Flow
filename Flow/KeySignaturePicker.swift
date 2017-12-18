//
//  KeySignatureDelegate.swift
//  Flow
//
//  Created by Vince on 18/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class KeySignaturePicker: UIPickerView {
    
    var keySignatures = [KeySignatureModel]()
    
    let customWidth:CGFloat = 100
    let customHeight: CGFloat = 100

}

extension KeySignaturePicker: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return keySignatures.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension KeySignaturePicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return customHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: customWidth, height: customHeight ))
        
        let keySignatureLabel = UILabel(frame: CGRect(x: 0, y: 0, width: customWidth, height: 30))
        
        keySignatureLabel.text = keySignatures[row].key.rawValue
        keySignatureLabel.textColor = .white
        keySignatureLabel.textAlignment = .center
        keySignatureLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.light)
        
        view.addSubview(keySignatureLabel)
        
        let keySignatureImage = UIImage(named: "sharp-white") // change to keySignatures[row].image
        
        let keySignatureImageView = UIImageView(frame: CGRect(x: (customWidth / 2) - ((keySignatureImage?.size.width)! / 2), y: 40, width: (keySignatureImage?.size.width)!, height: (keySignatureImage?.size.height)!))
        keySignatureImageView.image = keySignatureImage
        
        view.addSubview(keySignatureImageView)
        
        view.transform = CGAffineTransform(rotationAngle: (90 * (.pi / 180)))
        
        return view
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(keySignatures[row].key.rawValue)
    }
}
