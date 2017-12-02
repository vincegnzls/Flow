//
//  RestNoteType.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//
import UIKit

enum RestNoteType {
    case sixtyFourth,
        thirtySecond,
        sixteenth,
        eighth,
        quarter,
        half,
        whole
    
    func getRestImage() -> UIImage {
        switch self {
        case .sixtyFourth:
            return UIImage(named: "64th-rest")!
        case .thirtySecond:
            return UIImage(named: "32nd-rest")!
        case .sixteenth:
            return UIImage(named: "16th-rest")!
        case .eighth:
            return UIImage(named: "eighth-rest")!
        case .quarter:
            return UIImage(named: "quarter-rest")!
        case .half:
            return UIImage(named: "half-rest")!
        case .whole:
            return UIImage(named: "whole-rest")!
        }
    }
    
    func getNoteImage(isUpwards: Bool) -> UIImage {
        switch self {
        case .sixtyFourth:
            return UIImage(named: "64th-rest")!
        case .thirtySecond:
            return UIImage(named: "32nd-rest")!
        case .sixteenth:
            return UIImage(named: "16th-rest")!
        case .eighth:
            return UIImage(named: "eighth-rest")!
        case .quarter:
            return UIImage(named: "quarter-rest")!
        case .half:
            return UIImage(named: "half-rest")!
        case .whole:
            return UIImage(named: "whole-rest")!
        }
    }
}
