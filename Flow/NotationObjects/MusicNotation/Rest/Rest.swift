//
//  Rest.swift
//  Flow
//
//  Created by Kevin Chan on 03/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Rest: MusicNotation {
    // MARK: Properties
    var type: RestNoteType
    
    init(type: RestNoteType) {
        self.type = type
        super.init()
    }
    
    init(screenCoordinates: ScreenCoordinates?,
         gridCoordinates: GridCoordinates?,
         type: RestNoteType) {
        self.type = type
        super.init(screenCoordinates: screenCoordinates, gridCoordinates: gridCoordinates)
    }
    
    // Set the image based on the rest type
    override func setImage() {
        self.image = type.getRestImage()
    }
}
