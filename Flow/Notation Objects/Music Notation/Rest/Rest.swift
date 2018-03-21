//
//  Rest.swift
//  Flow
//
//  Created by Kevin Chan on 03/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Rest: MusicNotation {
    
    /*override init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType) {
        super.init(screenCoordinates: screenCoordinates, type: type)
    }*/
    
    // Set the image based on the rest type
    override func setImage() {
        self.image = type.getRestImage()
    }

    override func duplicate() -> Rest {
        return Rest(screenCoordinates: self.screenCoordinates, type: self.type, measure: self.measure)
    }
}
