//
//  EditAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class EditAction: Action {
    
    var measures: [Measure]
    var oldNotations: [MusicNotation]
    var newNotations: [MusicNotation]
    
    init(old oldNotations: [MusicNotation], new newNotations: [MusicNotation]) {
        self.measures = []
        self.oldNotations = oldNotations
        self.newNotations = newNotations
    }
    
    func execute() {

        /*for (notation, measure) in zip(oldNotations, measures) {
            measure.deleteInMeasure(notation)
        }*/
        
        // Delete notes in measures
        /*for notation in self.oldNotations {
            if let measure = notation.measure {
                if let index = measure.notationObjects.index(of: notation) {
                    self.notationIndices.append(index)
                    print("found index at: \(index)")
                }
                if !self.measures.contains(measure) {
                    self.measures.append(measure)
                }
                print("deleting notation")
                measure.deleteInMeasure(notation)
            }
        }*/

        var newIndex = 0
        for old in self.oldNotations {
            if let measure = old.measure {
                
                if newIndex < self.newNotations.count {
                    measure.replace(old, self.newNotations[newIndex])
                    newIndex += 1
                } else {
                    measure.remove(old)
                }
                
                if !self.measures.contains(measure) {
                    self.measures.append(measure)
                }
            }
        }

        var measureIndex = 0
        
        /*for (notation, index) in zip(self.newNotations, self.notationIndices) {
            if !measures[measureIndex].isAddNoteValid(musicNotation: notation.type) {
                measureIndex += 1
            }

            if measureIndex >= measures.count {
                break
            }

            let measure = measures[measureIndex]
            
            if index > -1 {
                measure.addToMeasure(notation, at: index)
            } else {
                measure.addToMeasure(notation)
            }
            
        }*/
        
        for i in newIndex..<self.newNotations.count {
            let notation = self.newNotations[i]
            
            if measureIndex < measures.count {
                if !measures[measureIndex].isAddNoteValid(musicNotation: notation.type) {
                    measureIndex += 1
                }
            }
            
            if measureIndex >= measures.count {
                break
            }
            
            let measure = measures[measureIndex]
            
            measure.add(notation)
        }

        //self.measures[0].addToMeasure(newNotations[0])

        /*for notation in newNotations {
            if !measures[measureIndex].isAddNoteValid(musicNotation: item.type) {
                measureIndex += 1
                noteIndex = 0
            }

            if measureIndex >= measures.count {
                break
            }


            let measure = measures[measureIndex]
            measure

        }*/
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
}
