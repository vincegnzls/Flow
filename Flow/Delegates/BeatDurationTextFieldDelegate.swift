//
//  BeatDurationTextFieldDelegate.swift
//  Flow
//
//  Created by Vince on 14/04/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class BeatDurationTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        
        return allowedCharacters.isSuperset(of: characterSet) && newLength <= 2
    }
}
