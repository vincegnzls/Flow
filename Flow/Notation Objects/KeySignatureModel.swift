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
    var image: UIImage?
    
    init(key: KeySignature, image: UIImage?) {
        self.key = key
        
        if let image = image {
            self.image = image
        }
    }
}
