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
    var id: String
    
    init(name: String, lastEdited: Date, id: String) {
        self.name = name
        self.lastEdited = lastEdited
        self.id = id
    }
    
    init(name: String, lastEdited: Date) {
        self.name = name
        self.lastEdited = lastEdited
        self.id = UUID().uuidString
    }
    
    init(name: String) {
        self.name = name
        self.lastEdited = Date()
        self.id = UUID().uuidString
    }
    
    init(lastEdited: Date) {
        self.name = "Untitled"
        self.lastEdited = lastEdited
        self.id = UUID().uuidString
    }
    
    init() {
        self.name = "Untitled"
        self.lastEdited = Date()
        self.id = UUID().uuidString
    }
}
