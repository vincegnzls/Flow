//
//  UndoRedo.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class UndoRedo {
    
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
        
    }
    
    func redo() {
        
    }
}
