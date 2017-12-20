//
//  KeySignature.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

enum KeySignature: Int {
    case
        c       = 0,
        f       = -1,
        bFlat   = -2,
        eFlat   = -3,
        aFlat   = -4,
        dFlat   = -5,
        gFlat   = -6,
        cFlat   = -7,
        g       = 1,
        d       = 2,
        a       = 3,
        e       = 4,
        b       = 5,
        fSharp  = 6,
        cSharp  = 7
    
    func toString() -> String {
        switch self {
        case .c:        return "C"
        case .f:        return "F"
        case .bFlat:    return "B Flat"
        case .eFlat:    return "E Flat"
        case .aFlat:    return "A Flat"
        case .dFlat:    return "D Flat"
        case .gFlat:    return "G Flat"
        case .cFlat:    return "C Flat"
        case .g:        return "G"
        case .d:        return "D"
        case .a:        return "A"
        case .e:        return "E"
        case .b:        return "B"
        case .fSharp:   return "F Sharp"
        case .cSharp:   return "C Sharp"
        }
    }
}
