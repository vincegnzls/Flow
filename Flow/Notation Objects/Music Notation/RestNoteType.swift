//
//  RestNoteType.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//
import UIKit

enum RestNoteType {
    
    case
        sixtyFourth,
        thirtySecond,
        sixteenth,
        eighth,
        quarter,
        half,
        whole
    
    static let types = [whole, half, quarter, eighth, sixteenth, thirtySecond, sixtyFourth]
    
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
            } else {
                return UIImage(named: "64th-down")!
            }
        case .thirtySecond:
            if isUpwards {
                return UIImage(named: "32nd-up")!
            } else {
                return UIImage(named: "32nd-down")!
            }
        case .sixteenth:
            if isUpwards {
                return UIImage(named: "16th-up")!
            } else {
                return UIImage(named: "16th-down")!
            }
        case .eighth:
            if isUpwards {
                return UIImage(named: "eighth-up")!
            } else {
                return UIImage(named: "eighth-down")!
            }
        case .quarter:
            if isUpwards {
                return UIImage(named: "quarter-up")!
            } else {
                return UIImage(named: "quarter-down")!
            }
        case .half:
            if isUpwards {
                return UIImage(named: "half-up")!
            } else {
                return UIImage(named: "half-down")!
            }
        case .whole:
            return UIImage(named: "whole-head")!
        }
    }
    
    func toString() -> String {
        switch self {
        case .sixtyFourth:      return "64th"
        case .thirtySecond:     return "32nd"
        case .sixteenth:        return "16th"
        case .eighth:           return "eighth"
        case .quarter:          return "quarter"
        case .half:             return "half"
        case .whole:            return "whole"
        }
    }
    
    static func convert(_ type: String) -> RestNoteType{
        switch type {
        case "64th": return .sixtyFourth
        case "32nd": return .thirtySecond
        case "16th": return .sixteenth
        case "eighth": return .eighth
        //case "quarter": return .quarter
        case "half": return .half
        case "whole": return .whole
        default: return .quarter
        }
    }
    
    func getDivision() -> Int {
        switch self {
        case .eighth:           return 2
        case .sixteenth:        return 4
        case .thirtySecond:     return 8
        case .sixtyFourth:      return 16
        default:                return 1
        }
    }
    
    func getDuration(divisions: Int) -> Int {
        switch self {
        case .sixtyFourth: return divisions / 16
        case .thirtySecond: return divisions / 8
        case .sixteenth: return divisions / 4
        case .eighth: return divisions / 2
        case .quarter: return divisions
        case .half: return divisions * 2
        case .whole: return divisions * 4
        }
    }
    
    func getBeatValue(dots: Int = 0) -> Float {
        var currentVal: Float
        
        switch self {
        case .sixtyFourth: currentVal = 0.015625
        case .thirtySecond: currentVal = 0.03125
        case .sixteenth: currentVal = 0.0625
        case .eighth: currentVal = 0.125
        case .quarter: currentVal = 0.25
        case .half: currentVal = 0.5
        case .whole: currentVal = 1.0
        }
        
        var halvedVal = currentVal / 2
        
        for _ in 0..<dots {
            currentVal += halvedVal
            halvedVal = halvedVal / 2
        }
        
        return currentVal
        
    }
    
}
