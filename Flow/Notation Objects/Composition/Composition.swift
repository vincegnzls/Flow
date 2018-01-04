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

    init(compositionInfo: CompositionInfo = CompositionInfo(), staffList: [Staff]) {
        self.compositionInfo = compositionInfo
        self.staffList = staffList
    }

    public func getStaffList () -> [Staff] {
        return self.staffList
    }

    public func isEnsembleStaff () -> Bool {
        return self.staffList.count > 1
    }

    public func getNumberOfStaffs () -> Int {
        return staffList.count
    }

    public func getNumberOfMeasures () -> Int {
        var measureNum = 0

        for i in 0..<staffList.count {
            measureNum += staffList[i].measures.count
        }

        return measureNum
    }
}
