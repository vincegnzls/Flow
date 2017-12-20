//
//  Clef.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

enum Clef: String {
    case
        G   = "G",
        F   = "F"
    
    func getStandardLine() -> Int {
        switch self {
        case .G: return 2
        case .F: return 4
        }
    }
}
