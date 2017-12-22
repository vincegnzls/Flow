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
}
