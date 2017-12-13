//
//  MusicNotation.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class MusicNotation {
    // MARK: Properties
    var screenCoordinates: CGPoint?
    var gridCoordinates: GridCoordinates?
    var image: UIImage?
    
    init() {
        self.setImage()
    }
    
    init(screenCoordinates: CGPoint?,
         gridCoordinates: GridCoordinates?) {
        self.screenCoordinates = screenCoordinates
        self.gridCoordinates = gridCoordinates
        
        self.setImage()
    }
    
    // Sets the image based on the music notation
    func setImage() {
        // Do nothing
    }
}
