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
    var measures: [Measure]
    
    init(compositionInfo: CompositionInfo = CompositionInfo(), measures: [Measure] = []) {
        self.compositionInfo = compositionInfo
        self.measures = measures
    }
}
