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
    
    init(screenCoordinates: ScreenCoordinates?,
         gridCoordinates: GridCoordinates?,
         type: RestNoteType) {
        self.type = type
        super.init(screenCoordinates: screenCoordinates, gridCoordinates: gridCoordinates)
    }
    
    // Set the image based on the rest type
    override func setImage() {
        switch self.type {
        case .sixtyFourth:
            self.image = UIImage(named: "64th-rest")
        case .thirtySecond:
            self.image = UIImage(named: "32nd-rest")
        case .sixteenth:
            self.image = UIImage(named: "16th-rest")
        case .eighth:
            self.image = UIImage(named: "eighth-rest")
        case .quarter:
            self.image = UIImage(named: "quarter-rest")
        case .half:
            self.image = UIImage(named: "half-rest")
        case .whole:
            self.image = UIImage(named: "whole-rest")
        }
    }
}
