//
//  Clipboard.swift
//  Flow
//
//  Created by Kevin Chan on 21/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Clipboard {
    
    // MARK: Shared instance
    static let instance = Clipboard()
    
    // MARK: Properties
    private var items: [MusicNotation]
    
    private init() {
        items = []
    }

    func cut(_ notations: [MusicNotation]) {
        self.items = notations
        for notation in notations {
            if let measure = notation.measure {
                measure.deleteInMeasure(notation)
                notation.measure = nil
            }
        }
    }

    func copy(_ notations: [MusicNotation]) {
        self.items.removeAll()
        for notation in notations {
            let newNotation = notation.duplicate()
            newNotation.measure = nil
            self.items.append(newNotation)
        }
    }

    func paste(measures: [Measure], measureIndex: inout Int, noteIndex: inout Int) {
        for item in self.items {
            if !measures[measureIndex].isAddNoteValid(musicNotation: item.type) {
                measureIndex += 1
                noteIndex = 0
            }

            if measureIndex >= measures.count {
                break
            }


            let measure = measures[measureIndex]
            measure

        }
    }
}
