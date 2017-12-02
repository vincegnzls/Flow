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
            if isUpwards {
                return UIImage(named: "64th-up")!
            }
            else {
                return UIImage(named: "64th-down")!
            }
        case .thirtySecond:
            if isUpwards {
                return UIImage(named: "32nd-up")!
            }
            else {
                return UIImage(named: "32nd-down")!
            }
        case .sixteenth:
            if isUpwards {
                return UIImage(named: "16th-up")!
            }
            else {
                return UIImage(named: "16th-down")!
            }
        case .eighth:
            if isUpwards {
                return UIImage(named: "eighth-up")!
            }
            else {
                return UIImage(named: "eighth-down")!
            }
        case .quarter:
            if isUpwards {
                return UIImage(named: "quarter-up")!
            }
            else {
                return UIImage(named: "quarter-down")!
            }
        case .half:
            if isUpwards {
                return UIImage(named: "half-up")!
            }
            else {
                return UIImage(named: "half-down")!
            }
        case .whole:
            if isUpwards {
                return UIImage(named: "whole-up")!
            }
            else {
                return UIImage(named: "whole-down")!
            }
        }
    }
}
