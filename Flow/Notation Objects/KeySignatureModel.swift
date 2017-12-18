//
//  KeySignature.swift
//  Flow
//
//  Created by Vince on 18/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class KeySignatureModel {
    
    var key: KeySignature
    var image: UIImage = UIImage()
    
    init(key:KeySignature) {
        self.key = key
    }
    
    init(key:KeySignature, image:UIImage) {
        self.key = key
        self.image = image
    }
}
