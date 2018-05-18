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
