//
//  CompositionInfo.swift
//  Flow
//
//  Created by Kevin Chan on 05/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

struct CompositionInfo: Codable {
    var name: String
    var lastEdited: Date
    
    init(name: String, lastEdited: Date) {
        self.name = name
        self.lastEdited = lastEdited
    }
    
    init(name: String) {
        self.name = name
        self.lastEdited = Date()
    }
    
    init(lastEdited: Date) {
        self.name = "Untitled"
        self.lastEdited = lastEdited
    }
    
    init() {
        self.name = "Untitled"
        self.lastEdited = Date()
    }
}
