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

    var type: ConnectionType? {
        didSet {
            print("CONN TYPEEEE: \(type)")
        }
    }

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

    public func replace(_ oldNote: Note, _ newNote: Note) {

        if let connection = oldNote.connection, let cNotes = connection.notes, let index = cNotes.index(of: oldNote) {
            if let newConnection = newNote.connection, let newCNotes = newConnection.notes {
                for newCNote in newCNotes {
                    if let connection = newCNote.connection {
                        connection.notes![index] = newNote
                    }
                }
            }

        } else {

        }

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
