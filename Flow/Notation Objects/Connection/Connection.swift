//
//  Connection.swift
//  Flow
//
//  Created by Kevin Chan on 25/05/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation

class Connection {

    var notes: [Note]? {
        didSet {
            if let notes = self.notes {
                if notes.count > 0 {
                    var isEqual = true
                    let initialPitch = notes[0].pitch
                    for notation in notes[1...] {
                        if notation.pitch != initialPitch {
                            isEqual = false
                            self.type = .slur
                            break
                        }
                    }

                    if isEqual {
                        self.type = .tie
                    }
                }
            }
        }
    }

    var type: ConnectionType?

    init(notes: [Note]? = nil, type: ConnectionType? = nil) {
        self.notes = notes
        self.type = type
    }

    func getFirstNote() -> Note? {
        if let notes = self.notes {
            if notes.count > 1 {
                if let first = notes.first {
                    return first
                }
            }
        }

        return nil
    }

    func getLastNote() -> Note? {
        if let notes = self.notes {
            if notes.count > 1 {
                if let last = notes.last {
                    return last
                }
            }
        }

        return nil
    }
}
