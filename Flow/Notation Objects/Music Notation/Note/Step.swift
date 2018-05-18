//
//  Step.swift
//  Flow
//
//  Created by Kevin Chan on 20/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//
enum Step: Int {
    case
    C,
    D,
    E,
    F,
    G,
    A,
    B
    
    func toValue() -> Int {
        switch self {
        case .C: return 2
        case .D: return 3
        case .E: return 4
        case .F: return 5
        case .G: return 6
        case .A: return 0
        case .B: return 1
        }
    }
    
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
