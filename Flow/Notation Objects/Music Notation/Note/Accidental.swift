//
//  Accidental.swift
//  Flow
//
//  Created by Kevin Chan on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

enum Accidental {
    case natural,
        sharp,
        flat,
        doubleSharp
    
    func toString() -> String {
        switch self {
        case .sharp: return "sharp"
        case .flat: return "flat"
        case .doubleSharp: return "double-sharp"
        default: return "natural"
        }
    }
    
    static func convert(_ accidental: String) -> Accidental {
        switch accidental {
        case "sharp": return .sharp
        case "flat": return .flat
        case "double-sharp": return .doubleSharp
        default: return .natural
        }
    }
}
