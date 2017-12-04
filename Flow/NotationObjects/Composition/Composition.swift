//
//  Composition.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Composition {
    var name: String
    var measures: Array<Measure>
    
    init() {
        self.name = "Untitled"
        self.measures = []
    }
    
    init(name: String) {
        self.name = name
        self.measures = []
    }
    
    init(measures: Array<Measure>) {
        self.name = "Untitled"
        self.measures = measures
    }
    
    init(name: String, measures: Array<Measure>) {
        self.name = name
        self.measures = measures
    }
}
