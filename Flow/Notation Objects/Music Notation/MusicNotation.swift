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
    
    init(screenCoordinates: CGPoint? = nil,
         type: RestNoteType,
         measure: Measure? = nil) {
        self.screenCoordinates = screenCoordinates
        self.type = type
        self.isSelected = false
        self.measure = measure
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
        return MusicNotation(screenCoordinates: self.screenCoordinates, type: self.type, measure: self.measure)
    }
    
    static func == (lhs: MusicNotation, rhs: MusicNotation) -> Bool {
        return lhs === rhs
    }

    func getBaseNotationSpace() -> CGFloat {

        // TODO: adjust this if dotted or with accidentals

        let noteHeadWidth = UIImage(named: "quarter-head")!.size.width - 3

        switch type {
            case .whole:
                return 14 * noteHeadWidth
            case .half:
                return 7 * noteHeadWidth
            case .quarter:
                return 3.5 * noteHeadWidth
            case .eighth:
                return 1.75 * noteHeadWidth
            case .sixteenth:
                return 0.875 * noteHeadWidth
            case .thirtySecond:
                return 0.4375 * noteHeadWidth
            case .sixtyFourth:
                return 0.21875 * noteHeadWidth
        }
    }

}
