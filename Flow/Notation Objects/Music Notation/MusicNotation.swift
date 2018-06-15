//
//  MusicNotation.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class MusicNotation: Equatable {
    // MARK: Properties
    var screenCoordinates: CGPoint?
    var type: RestNoteType {
        didSet {
            self.setImage()
        }
    }
    var image: UIImage?
    var imageView: UIImageView?
    var isSelected: Bool {
        didSet {
            self.setImage()
        }
    }
    var measure: Measure? {
        didSet {
            self.setImage()
        }
    }
    
    var dots = 0
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType,
         measure: Measure? = nil,
         dots: Int = 0) {
        self.screenCoordinates = screenCoordinates
        self.type = type
        self.isSelected = false
        self.measure = measure
        self.dots = dots
        self.setImage()

    }
    
    // Sets the image based on the music notation
    func setImage() {
        // Do nothing
    }

    func hasTail() -> Bool {
        return self.type.getBeatValue() <= RestNoteType.eighth.getBeatValue()
    }


    func duplicate() -> MusicNotation {
        return MusicNotation(screenCoordinates: self.screenCoordinates, type: self.type, measure: self.measure, dots: self.dots)
    }
    
    static func == (lhs: MusicNotation, rhs: MusicNotation) -> Bool {
        return lhs === rhs
    }

    func getBaseNotationSpace() -> CGFloat {

        let noteHeadWidth = UIImage(named: "quarter-head")!.size.width - 3

        let dotSpace: CGFloat = 5.0 * CGFloat(dots)
        
        switch type {
            case .whole:
                return 7 * noteHeadWidth + dotSpace
            case .half:
                return 3.5 * noteHeadWidth + dotSpace
            case .quarter:
                return 1.75 * noteHeadWidth + dotSpace
            case .eighth:
                return 0.875 * noteHeadWidth + dotSpace
            case .sixteenth:
                return 0.4375 * noteHeadWidth + dotSpace
            case .thirtySecond:
                return 0.21875 * noteHeadWidth + dotSpace
            case .sixtyFourth:
                return 0.109375 * noteHeadWidth + dotSpace
        }
    }

}
