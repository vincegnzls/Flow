//
//  Slur.swift
//  Flow
//
//  Created by Kevin Chan on 25/05/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation

class Slur: Connection {
    var notes: [Note] {
        get {
            return self.notes
        }
        
        set(newNotes) {
            if newNotes.count > 0 {
                var isEqual = true
                let initialPitch = newNotes[0].pitch
                for notation in newNotes[1...] {
                    if notation.pitch != initialPitch {
                        isEqual = false
                        break
                    }
                }
                
                if !isEqual {
                    self.notes = newNotes
                }
            }
        }
    }
    
    init(_ notes: [Note] = []) {
        self.notes = notes
    }
}
