//
//  DeleteAction.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class DeleteAction: Action {
    
    var measures: [Measure]
    var notations : [MusicNotation]
    var indices: [Int]
    
    init(notations: [MusicNotation]) {
        self.measures = []
        self.notations = notations
        self.indices = []
    }

    func execute() {
        var notationsToBeRemoved = [MusicNotation]()
        
        for notation in self.notations {
            if let measure = notation.measure {
                if let note = notation as? Note { // FOR DELETING GROUP OF NOTES FROM CHORDS
                    if let chord = note.chord {
                        self.indices.append(measure.notationObjects.index(of: chord)!)
                        chord.removeNote(note: note)
                        self.measures.append(measure)
                    } else {
                        self.indices.append(measure.notationObjects.index(of: notation)!)
                        notationsToBeRemoved.append(notation)
                        self.measures.append(measure)
                    }
                } else {
                    self.indices.append(measure.notationObjects.index(of: notation)!)
                    notationsToBeRemoved.append(notation)
                    self.measures.append(measure)
                }
            }
        }
        
        for notation in notationsToBeRemoved {
            if let measure = notation.measure {
                measure.remove(notation)
            }
        }
        
        UndoRedoManager.instance.addActionToUndoStack(self)
    }
    
    func undo() {
        print("Number of measures: \(self.measures.count)")
        print("Number of notation: \(self.notations.count)")
        print("Number of indices: \(self.indices.count)")
        for (i, measure) in self.measures.enumerated() {
            let notation = self.notations[i]
            
            if let note = notation as? Note {
                if let previousChord = note.chord {
                    let index = self.indices[i]
                    
                    if measure.notationObjects.count > index {
                        if measure.notationObjects[index] is Chord {
                            
                            let chord = measure.notationObjects[index] as? Chord
                            
                            chord?.notes.append(note)
                            
                        } else if measure.notationObjects[index] is Note {
                            
                            if let existingNote = measure.notationObjects[index] as? Note {
                                previousChord.notes.append(note)
                                existingNote.chord = previousChord
                                
                                measure.replace(existingNote, previousChord)
                            }
                            
                        }
                    } else {
                        let index = self.indices[i]
                        measure.add(previousChord, at: index)
                    }
                    
                } else {
                    let index = self.indices[i]
                    measure.add(notation, at: index)
                }
            } else {
                let index = self.indices[i]
                measure.add(notation, at: index)
            }
        }
    }
    
    func redo() {
        for notation in self.notations {
            if let measure = notation.measure {
                if let note = notation as? Note { // FOR DELETING GROUP OF NOTES FROM CHORDS
                    if let chord = note.chord {
                        chord.removeNote(note: note)
                    } else {
                        measure.remove(notation)
                    }
                } else {
                    measure.remove(notation)
                }
            }
        }
    }
    
}
