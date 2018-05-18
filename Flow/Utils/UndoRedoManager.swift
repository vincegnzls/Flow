//
//  UndoRedo.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class UndoRedoManager {
    // MARK: Constants
    private static let MAX_ACTIONS = 10
    
    // MARK: Shared instance
    static let instance = UndoRedoManager()
    
    // MARK: Properties
    var undoStack: [Action]
    var redoStack: [Action]
    
    private init() {
        self.undoStack = []
        self.redoStack = []
    }
    
    func undo() {
//        print("Number of actions in undo stack: \(self.undoStack.count)")
        if let action = self.undoStack.popLast() {
            action.undo()
            EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
            
            self.addActionToRedoStack(action)
        }
    }
    
    func redo() {
        if let action = self.redoStack.popLast() {
            action.redo()
            EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
            
            self.addActionToUndoStack(action)
        }
    }
    
    func addActionToUndoStack(_ action: Action) {
        self.undoStack.append(action)
        
        // Limit number of actions stored to save memory
        if self.undoStack.count > UndoRedoManager.MAX_ACTIONS {
            self.undoStack.removeFirst()
        }
    }
    
    private func addActionToRedoStack(_ action: Action) {
        self.redoStack.append(action)
        
        // Limit number of actions stored to save memory
        if self.redoStack.count > UndoRedoManager.MAX_ACTIONS {
            self.redoStack.removeFirst()
        }
    }
}
