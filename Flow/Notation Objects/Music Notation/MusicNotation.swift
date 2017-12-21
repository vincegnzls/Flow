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
    var type: RestNoteType {
        didSet {
            self.setImage()
        }
    }
    var image: UIImage?
    var imageView: UIImageView?
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType) {
        self.screenCoordinates = screenCoordinates
        self.type = type
        
        self.setImage()
    }
    
    // Sets the image based on the music notation
    func setImage() {
        // Do nothing
    }
}
