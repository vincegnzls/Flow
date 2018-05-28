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
        self.edit()
        UndoRedoManager.instance.addActionToUndoStack(self)
    }

    private func edit() {

        var index = 0
        
        for oldNotation in self.oldNotations {
            if self.oldNotations.count == self.newNotations.count {
                if index < self.newNotations.count {
                    if let oldNote = oldNotation as? Note, let newNote = self.newNotations[index] as? Note {
                        if let newConnection = newNote.connection {
                            newConnection.replace(oldNote, newNote)
                        } else if let oldConnection = oldNote.connection {
                            if self.newNotations.count == 1 {
                                //oldConnection.notes!.remove(at: oldConnection.notes!.index(of: oldNote)!)
                                newNote.connection = oldConnection
                                oldConnection.replace(oldNote, newNote)
                                newNote.connection = oldConnection
                            }
                        }
                    }
                    
                    index += 1
                }
            } else {
                if oldNotations.count > newNotations.count {
                    /*if let oldNote = oldNotation as? Note, let oldConn = oldNote.connection {
                        for oldNote2 in self.oldNotations {
                            if let oldNote3 = oldNote2 as? Note {
                                oldConn.notes!.remove(at: oldConn.notes!.index(of: oldNote3)!)
                            }
                        }
                        
                        //oldConn.note!.
                    }*/
                    
                    if let oldNote = oldNotation as? Note {
                        
                        if let newNote = newNotations.first as? Note {
                            newNote.connection = oldNote.connection
                        }
                        
                        if let oldConn = oldNote.connection {
                            for oldNoteConn in oldConn.notes! {
                                oldNoteConn.connection = nil
                            }
                        }
                        
                        oldNote.connection = nil
                        
                        /*if oldNote == self.oldNotations.last {
                            if let newNote = newNotations.first as? Note, let newNoteConn = newNote.connection {
                                newNoteConn.replace(oldNote, newNote)
                            }
                        }*/
                    }
                }
            }
        }

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
        
        let params = Parameters()
        params.put(key: KeyNames.ACTION_DONE, value: self)
        params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.EXECUTE)
        EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
    }
    
    func undo() {
        var newIndex = 0
        for new in self.newNotations {
            if let measure = new.measure {
                
                if newIndex < self.oldNotations.count {
                    measure.replace(new, self.oldNotations[newIndex])
                    
                    if let oldNote = self.oldNotations[newIndex] as? Note, let newNote = new as? Note, let newConn = newNote.connection {
                        newConn.replace(newNote, oldNote)
                    }
                    
                    newIndex += 1
                } else {
                    measure.remove(new)
                }
            }
        }
        
        var measureIndex = 0
        
        for i in newIndex..<self.oldNotations.count {
            let notation = self.oldNotations[i]
            
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
        
        let params = Parameters()
        params.put(key: KeyNames.ACTION_DONE, value: self)
        params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.UNDO)
        EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
    }
    
    func redo() {
        self.edit()
        
        let params = Parameters()
        params.put(key: KeyNames.ACTION_DONE, value: self)
        params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.REDO)
        EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
    }
    
}
