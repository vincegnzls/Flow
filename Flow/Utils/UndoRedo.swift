//
//  UndoRedo.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class UndoRedo {
    // MARK: Constants
    private static let MAX_ACTIONS = 10
    
    // MARK: Shared instance
    static let instance = UndoRedo()
    
    // MARK: Properties
    var undoStack: [Action]
    var redoStack: [Action]
    
    private init() {
        self.undoStack = []
        self.redoStack = []
    }
    
    func undo() {
        if let action = self.undoStack.popLast() {
            action.undo()
            self.addActionToRedoStack(action)
        }
    }
    
    func redo() {
        if let action = self.redoStack.popLast() {
            action.redo()
            self.addActionToUndoStack(action)
        }
    }
    
    func addActionToUndoStack(_ action: Action) {
        self.undoStack.append(action)
        
        // Limit number of actions stored to save memory
        if self.undoStack.count > UndoRedo.MAX_ACTIONS {
            self.undoStack.removeFirst()
        }
    }
    
    private func addActionToRedoStack(_ action: Action) {
        self.redoStack.append(action)
        
        // Limit number of actions stored to save memory
        if self.redoStack.count > UndoRedo.MAX_ACTIONS {
            self.redoStack.removeFirst()
        }
    }
}
