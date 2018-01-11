//
//  Composition.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Composition {
    // Holds information about the composition
    var compositionInfo: CompositionInfo
    var staffList: [Staff]
    var isEnsembleStaff: Bool {
        return self.staffList.count > 1
    }
    var numStaves: Int {
        return self.staffList.count
    }
    var numMeasures: Int {
        var measureNum = 0
        
        for staff in staffList {
            measureNum += staff.measures.count
        }
        
        return measureNum
    }
    var all: [MusicNotation] {
        var notations = [MusicNotation]()
        
        for staff in staffList {
            for measure in staff.measures {
                notations.append(contentsOf: measure.notationObjects)
            }
        }
        return notations
    }
    
    init(compositionInfo: CompositionInfo = CompositionInfo(), staffList: [Staff] = []) {
        self.compositionInfo = compositionInfo
        self.staffList = staffList
    }
    
    func addStaff(_ staff: Staff) {
        self.staffList.append(staff)
    }
}
