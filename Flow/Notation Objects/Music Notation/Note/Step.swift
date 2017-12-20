//
//  Step.swift
//  Flow
//
//  Created by Kevin Chan on 20/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//
enum Step {
    case
    C,
    D,
    E,
    F,
    G,
    A,
    B
    
    func toString() -> String {
        switch self {
        case .C: return "C"
        case .D: return "D"
        case .E: return "E"
        case .F: return "F"
        case .G: return "G"
        case .A: return "A"
        case .B: return "B"
        }
    }
    
    static func convert(_ step: String) -> Step {
        switch step {
        case "D": return .D
        case "E": return .E
        case "F": return .F
        case "G": return .G
        case "A": return .A
        case "B": return .B
        default: return .C        
        }
    }
}
